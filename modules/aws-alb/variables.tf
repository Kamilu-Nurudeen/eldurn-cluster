variable "aws_lb_controller_chart" {
  type        = string
  description = "Helm chart name for aws_lb_controller"
  default     = "aws-load-balancer-controller"
}

variable "aws_lb_controller_chart_version" {
  type        = string
  description = "Helm chart version for aws_lb_controller"
  default     = "1.13.3"
}

variable "aws_lb_controller_version" {
  type        = string
  description = "aws_lb_controller docker version"
  default     = "v2.13.3"
}

variable "aws_lb_controller_repository" {
  type        = string
  description = "Helm chart repository for aws_lb_controller"
  default     = "https://aws.github.io/eks-charts"
}

variable "cluster_id" {
  type        = string
  description = "cluster oidc issuer for IRSA"
}

variable "oidc_provider_arn" {
  type        = string
  description = "cluster oidc provider ARN"
}

variable "service_account" {
  type        = string
  description = "Name of the k8s service account"
  default     = "aws-load-balancer-controller"
}
