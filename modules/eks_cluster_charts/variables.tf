variable "cluster_id" {
  type        = string
  description = "cluster oidc issuer for IRSA"
}

variable "oidc_provider_arn" {
  type        = string
  description = "cluster oidc provider ARN"
}

variable "aws_lb_controller_chart_version" {
  type        = string
  description = "aws_lb_controller helm chart version"
}

variable "aws_lb_controller_version" {
  type        = string
  description = "aws_lb_controller docker version"
}
