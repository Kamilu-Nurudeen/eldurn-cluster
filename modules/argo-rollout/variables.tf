variable "argo_rollout_namespace" {
  type    = string
  default = "argo-rollout"
}

variable "argo_rollout_helm_repository" {
  type    = string
  default = "https://argoproj.github.io/argo-helm"
}

variable "argo_rollout_helm_chart" {
  type    = string
  default = "argo-rollouts"
}

variable "argo_rollout_helm_release_name" {
  type    = string
  default = "argo-rollout"
}

variable "argo_rollout_helm_version" {
  type    = string
  default = "2.40.1"
}

variable "argo_rollout_dashboard_url" {
  type = string
}
