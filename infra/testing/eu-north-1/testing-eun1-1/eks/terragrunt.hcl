include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "eks" {
  path   = "${get_repo_root()}/common/eks.hcl"
  expose = true
}

terraform {
  source = include.eks.locals.source_base_url
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars         = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_id       = local.account_vars.locals.aws_account_id
  cluster_name     = local.env_vars.locals.name
}

inputs = {

  cluster_version = "1.33"

  cluster_addon_kube_proxy_version     = "v1.33.0-eksbuild.2"
  vpc_cni_addon_version                = "v1.19.6-eksbuild.7"
  cluster_addon_coredns_version        = "v1.12.2-eksbuild.4"

  default-node-group = {
    min_size     = 1
    max_size     = 2
    desired_size = 1
    update_config = {
      max_unavailable_percentage = 10
    }
    instance_types               = ["r5b.2xlarge"]
    create_security_group        = false
    iam_role_additional_policies = {
      "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 100
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          encrypted             = true
          delete_on_termination = true
        }
      }
    }
    labels = {
      "node-group" = "default"
    }
  }

}
