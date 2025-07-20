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
}

inputs = {
  aws_lb_controller_chart_version = "1.13.3"
  aws_lb_controller_version       = "v2.13.3"

  ebs_csi_driver_enabled = true
  ebs_csi_driver_chart_version = "2.46.0"
}
