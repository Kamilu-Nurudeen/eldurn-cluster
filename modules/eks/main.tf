locals {

  ports = [
    {
      description = "Envoy ports admin port / outbound"
      from_port   = 15000
      to_port     = 15090
    },
    {
      description = "aws-load-balancer-controller"
      from_port   = 9443
      to_port     = 9443
    },
    {
      description = "metrics-server"
      from_port   = 10250
      to_port     = 10250
    },
    {
      description = "api-webhooks"
      from_port   = 443
      to_port     = 443
    },
    {
      description = "allowing all the ports in the security group itself"
      from_port   = 0
      to_port     = 65535
    }
  ]

  ingress_rules = {
    for ikey, ivalue in local.ports :
    "${ikey}_ingress" => {
      description = ivalue.description
      protocol    = "tcp"
      from_port   = ivalue.from_port
      to_port     = ivalue.to_port
      type        = "ingress"
      self        = true
    }
  }

  egress_rules = {
    for ekey, evalue in local.ports :
    "${ekey}_egress" => {
      description = evalue.description
      protocol    = "tcp"
      from_port   = evalue.from_port
      to_port     = evalue.to_port
      type        = "egress"
      self        = true
    }
  }

  cluster_name_tag = !var.add_cluster_tag ? {} : { cluster = var.cluster_name }


}

resource "aws_kms_key" "eks" {
  description             = "EKS secret key for ${var.cluster_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_security_group" "additional" {
  vpc_id      = var.vpc_id
  name        = "${var.cluster_name}-additional-sg"
  description = "Allow HTTP in to nodes"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow EKS endpoint access internally"
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.cluster_name}-additional-sg"
      cluster = var.cluster_name
    }
  )

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_additional_security_group_ids = [aws_security_group.additional.id]
  cluster_endpoint_private_access       = true
  cluster_endpoint_public_access        = true
  enable_irsa                           = true

  tags = merge(
    var.tags,
    local.cluster_name_tag
  )

  cluster_addons = merge(
    {
      coredns = {
        addon_version     = var.cluster_addon_coredns_version
        resolve_conflicts = "OVERWRITE"
      }
      kube-proxy = {
        addon_version     = var.cluster_addon_kube_proxy_version
        resolve_conflicts = "OVERWRITE"
      }
    }
  )

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cluster_encryption_config = {
    "resources"        = ["secrets"]
    "provider_key_arn" = aws_kms_key.eks.arn
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  eks_managed_node_group_defaults = {
    ebs_optimized           = true
    disk_size               = 100
    instance_types          = [var.worker_default_size]
    pre_bootstrap_user_data = <<-EOT
      #!/bin/bash
      set -ex
      # To enable session manager
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl enable amazon-ssm-agent
      sudo systemctl start amazon-ssm-agent
    EOT
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "optional"
      http_put_response_hop_limit = 2
    }
    timeouts              = var.node_group_timeouts
    create_security_group = false
  }

  eks_managed_node_groups = {
    default = merge({}, var.default-node-group)
  }



  node_security_group_additional_rules = merge(
    local.ingress_rules,
    local.egress_rules,
    {
      control_plane = {
        description                   = "Allow control plane access to nodes"
        protocol                      = "-1"
        from_port                     = 0
        to_port                       = 0
        type                          = "ingress"
        source_cluster_security_group = true
      }
    }
  )
  cluster_timeouts    = var.cluster_timeouts
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    candidate_admin = {
      principal_arn = "arn:aws:iam::${var.account_id}:user/candidate"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    platform_bot = {
      principal_arn = "arn:aws:iam::${var.account_id}:role/${var.assume_role_name}"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  subnet_ids = var.private_subnets
  vpc_id     = var.vpc_id
}
# Data source to get subnet information including availability zones
data "aws_subnet" "rfc6598_subnets" {
  for_each = toset(var.rfc6598_subnet_ids)
  id       = each.value
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_addon_version
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = jsonencode({
    env = {
      # Reference: https://docs.aws.amazon.com/eks/latest/best-practices/custom-networking.html
      AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
      ENI_CONFIG_LABEL_DEF               = "failure-domain.beta.kubernetes.io/zone"

      # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
    eniConfig = {
      create = true
      region = var.aws_region
      subnets = {
        for subnet_id, subnet_data in data.aws_subnet.rfc6598_subnets : subnet_data.availability_zone => {
          id             = subnet_id
          securityGroups = [module.eks.node_security_group_id]
        }
      }
    }
  })

}
