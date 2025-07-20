include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "eks_cluster_charts" {
  path   = "${get_repo_root()}/common/eks_cluster_charts.hcl"
  expose = true
}

terraform {
  source = include.eks_cluster_charts.locals.source_base_url
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_id   = local.account_vars.locals.aws_account_id
  cluster_name = local.env_vars.locals.name
}

inputs = {
  aws_lb_controller_chart_version = "1.13.3"
  aws_lb_controller_version       = "v2.13.3"

  ebs_csi_driver_enabled = true
  ebs_csi_driver_chart_version = "2.46.0"

  metric_server_helm_chart_version = "3.12.2"
  metric_server_resources = {
    requests = {
      cpu    = "200m"
      memory = "200Mi"
    }
  }

  karpenter_enabled = true
  karpenter_chart_enabled = true
  karpenter_crd_chart_enabled = true
  karpenter_chart_v = "1.6.0"
  karpenter_crd_chart_v = "1.6.0"
  karpenter_replicas = 1
  

  availability_zones = dependency.vpc.outputs.vpc_azs
  
  
  # EC2NodeClass configurations
  ec2_nodeclasses = {
    "default" = {
      ami_family = "AL2023"
      associate_public_ip_address = false
      block_device_mappings = [
        {
          deviceName = "/dev/xvda"
          ebs = {
            volumeSize          = "100Gi"
            volumeType          = "gp3"
            deleteOnTermination = true
            encrypted           = true
            iops                = 3000
            throughput          = 150
          }
        }
      ]
      tags = {
        "node-type" = "default"
        "workload" = "general"
      }
    }
    
    "high-memory" = {
      ami_family = "AL2023"
      associate_public_ip_address = false
      block_device_mappings = [
        {
          deviceName = "/dev/xvda"
          ebs = {
            volumeSize          = "200Gi"
            volumeType          = "gp3"
            deleteOnTermination = true
            encrypted           = true
            iops                = 3000
            throughput          = 150
          }
        }
      ]
      tags = {
        "node-type" = "high-memory"
        "workload" = "memory-intensive"
      }
    }
  }

  # NodePool configurations
  nodepools = {
    "default" = {
      node_class_ref = "default"
      requirements = [
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values   = dependency.vpc.outputs.vpc_azs
        },
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
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
        },
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["on-demand"]
        }
      ]
      weight = 50
      disruption = {
        consolidation_policy = "WhenEmptyOrUnderutilized"
        consolidate_after    = "1m"
        budgets = [
          {
            nodes = "10%"
          }
          # Example of more complex budget configurations:
          # {
          #   nodes = "20%"
          #   reasons = ["Empty", "Drifted"]
          # },
          # {
          #   nodes = "5"
          # },
          # {
          #   nodes = "0"
          #   schedule = "@daily"
          #   duration = "10m"
          #   reasons = ["Underutilized"]
          # }
        ]
      }
      template = {
        metadata = {
          labels = {
            "node-type" = "default"
            "workload" = "general"
          }
          annotations = {
            "node.alpha.kubernetes.io/ttl" = "0"
          }
        }
      }
    }

    "high-memory" = {
      node_class_ref = "high-memory"
      requirements = [
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values   = dependency.vpc.outputs.vpc_azs
        },
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
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = ["r5.2xlarge", "r5a.2xlarge", "r5d.2xlarge"]
        },
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["on-demand"]
        }
      ]
      weight = 20
      disruption = {
        consolidation_policy = "WhenEmptyOrUnderutilized"
        consolidate_after    = "1m"
        budgets = [
          {
            nodes = "10%"
            schedule = "@daily"
            duration = "10m"
          }
        ]
      }
      template = {
        metadata = {
          labels = {
            "node-type" = "high-memory"
            "workload"  = "memory-intensive"
          }
          annotations = {
            "node.alpha.kubernetes.io/ttl" = "0"
          }
        }
      }
    }
  }



  karpenter_default_labels = {
    "managed-by" = "karpenter"
  }

  karpenter_default_tags = {
    "Cluster"     = "${local.cluster_name}"
    "Environment" = "testing"
    "managed-by" = "karpenter"
  }
}
