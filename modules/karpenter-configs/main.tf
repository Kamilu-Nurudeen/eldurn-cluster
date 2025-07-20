locals {
  default_ami_family = "AL2023"
  default_user_data  = <<-EOT
    #!/bin/bash
    set -ex
    # To enable session manager
    sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
  EOT

  # Default values for NodePool
  default_weight               = 1
  default_consolidation_policy = "WhenEmptyOrUnderutilized"
  default_consolidate_after    = "1m"
  default_capacity_type        = ["on-demand"]
}

# EC2NodeClass Resource
resource "kubernetes_manifest" "ec2_nodeclass" {
  for_each = var.ec2_nodeclasses

  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = each.key
      annotations = merge(
        each.value.annotations != null ? each.value.annotations : {},
        var.default_annotations
      )
      labels = merge(
        each.value.labels != null ? each.value.labels : {},
        var.default_labels
      )
    }
    spec = {
      amiFamily                = each.value.ami_family != null ? each.value.ami_family : local.default_ami_family
      role                     = var.karpenter_nodes_iam_role_name
      associatePublicIPAddress = var.associate_public_ip_address
      amiSelectorTerms = [
        {
          "alias" = each.value.ami_selector_alias != null ? each.value.ami_selector_alias : "al2023@latest"
        }
      ]
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery"          = var.cluster_name
            "kubernetes.io/role/internal-elb" = "1"
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      blockDeviceMappings = each.value.block_device_mappings != null ? each.value.block_device_mappings : [{
        deviceName = "/dev/xvda"
        ebs = {
          volumeSize          = "100Gi"
          volumeType          = "gp3"
          deleteOnTermination = true
          encrypted           = true
          iops                = 3000
          throughput          = 150
        }
      }]
      metadataOptions = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpTokens              = "optional"
        httpPutResponseHopLimit = "2"
      }
      userData = each.value.user_data != null ? each.value.user_data : local.default_user_data
      tags = merge(
        each.value.tags != null ? each.value.tags : {},
        var.default_tags
      )
    }
  }
}

# NodePool Resource
resource "kubernetes_manifest" "nodepool" {
  for_each = var.nodepools

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = each.key
      annotations = merge(
        each.value.annotations != null ? each.value.annotations : {},
        var.default_annotations
      )
      labels = merge(
        each.value.labels != null ? each.value.labels : {},
        var.default_labels
      )
    }
    spec = {
      disruption = {
        consolidationPolicy = each.value.disruption != null && each.value.disruption.consolidation_policy != null ? each.value.disruption.consolidation_policy : local.default_consolidation_policy
        consolidateAfter    = each.value.disruption != null && each.value.disruption.consolidate_after != null ? each.value.disruption.consolidate_after : local.default_consolidate_after
        budgets             = each.value.disruption != null && each.value.disruption.budgets != null ? each.value.disruption.budgets : []
      }
      template = {
        metadata = {
          labels = merge(
            each.value.template != null && each.value.template.metadata != null && each.value.template.metadata.labels != null ? each.value.template.metadata.labels : {},
            var.default_labels
          )
          annotations = merge(
            each.value.template != null && each.value.template.metadata != null && each.value.template.metadata.annotations != null ? each.value.template.metadata.annotations : {},
            var.default_annotations
          )
        }
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = each.value.node_class_ref != null ? each.value.node_class_ref : each.key
          }
          requirements = each.value.requirements != null ? each.value.requirements : [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = each.value.capacity_type != null ? each.value.capacity_type : local.default_capacity_type
            },
            {
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values   = each.value.availability_zones != null ? each.value.availability_zones : var.availability_zones
            }
          ]
        }
      }
      weight = each.value.weight != null ? each.value.weight : local.default_weight
    }
  }


  depends_on = [
    kubernetes_manifest.ec2_nodeclass,
  ]
}
