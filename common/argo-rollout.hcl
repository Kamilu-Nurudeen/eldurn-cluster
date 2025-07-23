locals {
  source_base_url = "${get_repo_root()}/modules/argo-rollout"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  aws_region                 = local.region_vars.locals.aws_region
  aws_account_id             = local.account_vars.locals.aws_account_id
  assume_role_name           = local.account_vars.locals.assume_role_name
  cluster_name               = local.env_vars.locals.name
}


dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../eks"

  mock_outputs = {
    cluster_ca_certificate  = "cGxhY2Vob2xkZXI="
    cluster_endpoint        = "placeholder"
    cluster_id              = "placeholder"
    cluster_token           = "placeholder"
    oidc_provider_arn       = "placeholder"
    cluster_oidc_issuer_url = "placeholder"
  }

  mock_outputs_merge_with_state = true
}


generate "provider_helm" {
  path      = "provider_helm.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "helm" {
  kubernetes = {
    host                   = "${dependency.eks.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.eks.outputs.cluster_ca_certificate}")
    exec = {
      api_version = "client.authentication.k8s.io/v1"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        "${local.cluster_name}",
        "--region",
        "${local.aws_region}",
        "--role",
        "arn:aws:iam::${local.aws_account_id}:role/${local.assume_role_name}"
      ]
      command = "aws"
    }
  }
}
EOF
}

inputs = {
  argo_rollout_helm_release_name = "argo-rollout"
  argo_rollout_helm_repository = "https://argoproj.github.io/argo-helm"
  argo_rollout_helm_chart = "argo-rollouts"
  argo_rollout_helm_version = "2.40.1"
}
