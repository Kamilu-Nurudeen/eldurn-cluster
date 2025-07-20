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

variable "ebs_csi_driver_enabled" {
  type        = bool
  description = "enable ebs csi driver"
  default     = false
}

variable "ebs_csi_driver_chart_version" {
  type        = string
  description = "ebs csi driver helm chart version"
  default     = "2.46.0"
}

variable "ebs_csi_driver_repository" {
  type        = string
  description = "ebs csi driver docker repository"
  default     = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
}

variable "metric_server_helm_repository" {
  type        = string
  description = "metric server helm repository"
  default     = "https://kubernetes-sigs.github.io/metrics-server"
}

variable "metric_server_helm_chart_version" {
  type        = string
  description = "metric server helm chart version"
  default     = "3.12.2"
}

variable "metric_server_resources" {
  type = map(object({
    cpu    = string
    memory = string
  }))
}
