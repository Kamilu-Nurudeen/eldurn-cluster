include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "argo_rollout" {
  path   = "${get_repo_root()}/common/argo-rollout.hcl"
  expose = true
}

terraform {
  source = include.argo_rollout.locals.source_base_url
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_id   = local.account_vars.locals.aws_account_id
  cluster_name = local.env_vars.locals.name
}

inputs = {
  argo_rollout_dashboard_url = "argorollouts.${local.env_vars.locals.name}.eldurn.com"
}

