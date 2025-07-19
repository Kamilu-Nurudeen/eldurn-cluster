locals {
  source_base_url = "${get_repo_root()}/modules/eks"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  aws_region     = local.region_vars.locals.aws_region
  aws_account_id = local.account_vars.locals.aws_account_id
  environment    = local.env_vars.locals.environment
  assume_role_name = local.account_vars.locals.assume_role_name
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"

  mock_outputs = {
    name                   = "placeholder"
    vpc_private_subnet_ids = ["placeholder"]
    rfc6598_subnet_ids     = ["placeholder"]
    vpc_id                 = "placeholder"
  }

  mock_outputs_merge_with_state = true
}

inputs = {
  account_id      = local.aws_account_id
  aws_region      = local.aws_region
  cluster_name    = dependency.vpc.outputs.name
  private_subnets = dependency.vpc.outputs.vpc_private_subnet_ids
  region          = local.aws_region
  vpc_id          = dependency.vpc.outputs.vpc_id
  rfc6598_subnet_ids = dependency.vpc.outputs.rfc6598_subnet_ids
  environment     = local.environment
  assume_role_name = local.assume_role_name
}
