locals {
  source_base_url = "${get_repo_root()}/modules/vpc"

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment          = local.env_vars.locals.environment
  name                 = local.env_vars.locals.name
  vpc_private_cidr     = local.env_vars.locals.vpc_private_cidr
  vpc_public_cidr      = local.env_vars.locals.vpc_public_cidr
  enable_vpc_endpoints = local.env_vars.locals.enable_vpc_endpoints
  rfc6598_subnets      = local.env_vars.locals.additional_vpc_cidrs
}

inputs = {
  environment          = local.environment
  name                 = local.name
  private_cidr         = local.vpc_private_cidr
  public_cidr          = local.vpc_public_cidr
  enable_vpc_endpoints = local.enable_vpc_endpoints
  rfc6598_subnets      = local.rfc6598_subnets
}
