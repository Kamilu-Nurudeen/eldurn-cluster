locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment      = local.env_vars.locals.environment
  aws_region       = local.region_vars.locals.aws_region
  aws_account_id   = local.account_vars.locals.aws_account_id
  assume_role_name = local.account_vars.locals.assume_role_name
  cluster_name     = local.env_vars.locals.name

  tags = {
    "managed_by"        = "terraform"
    "environment"       = local.environment
  }
}

generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  assume_role {
    role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.assume_role_name}"
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "eldurn-infra-tfstate"
    key            = "${path_relative_to_include()}/eldurn-infra.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    use_lockfile   = true
    assume_role = {
      role_arn = "arn:aws:iam::594081136085:role/${local.assume_role_name}"
    }
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  {
    tags = local.tags
  }
)

