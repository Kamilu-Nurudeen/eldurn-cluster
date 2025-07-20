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

variable "karpenter_enabled" {
  type        = bool
  description = "enable karpenter"
  default     = true
}
variable "karpenter_chart_enabled" {
  type        = bool
  description = "enable karpenter chart"
  default     = true
}

variable "karpenter_crd_chart_enabled" {
  type        = bool
  description = "enable karpenter crd chart"
  default     = true
}

variable "karpenter_chart_v" {
  type        = string
  description = "karpenter chart version"
  default     = "1.6.0"
}

variable "karpenter_crd_chart_v" {
  type        = string
  description = "karpenter crd chart version"
  default     = "1.6.0"
}

variable "cluster_endpoint" {
  type        = string
  description = "cluster endpoint"
}

variable "karpenter_replicas" {
  type        = number
  description = "karpenter replicas"
  default     = 1
}

# Karpenter Configuration
variable "ec2_nodeclasses" {
  type        = map(any)
  description = "Map of EC2NodeClass configurations"
  default     = {}
}

variable "nodepools" {
  type        = map(any)
  description = "Map of NodePool configurations"
  default     = {}
}

variable "karpenter_default_annotations" {
  type        = map(string)
  description = "Default annotations for Karpenter resources"
  default     = {}
}

variable "karpenter_default_labels" {
  type        = map(string)
  description = "Default labels for Karpenter resources"
  default     = {}
}

variable "karpenter_default_tags" {
  type        = map(string)
  description = "Default tags for Karpenter EC2 instances"
  default     = {}
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the region"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Whether to associate public IP addresses to EC2 instances"
  default     = false
}
