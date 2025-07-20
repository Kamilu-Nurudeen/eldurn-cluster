variable "cluster_id" {
  description = "The ID of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to AWS resources"
  type        = map(string)
  default     = {}
}


variable "ebs_csi_driver_chart" {
  type        = string
  description = "Helm chart name"
  default     = "aws-ebs-csi-driver"
}

variable "ebs_csi_driver_chart_version" {
  type        = string
  description = "Helm chart version"
  default     = "2.46.0"
}

variable "ebs_csi_driver_repository" {
  type        = string
  description = "Helm chart repository"
  default     = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
}

variable "helm_release_timeout" {
  type        = number
  description = "helm release timout in seconds. default 300s is failing because of slow daemonset rollouts. set it to 30min"
  default     = 1800
}

variable "helm_values_override_file" {
  description = "Helm Release values file. Should be a valid YAML file."
  type        = string
  default     = null
}

variable "additional_labels" {
  type        = map(string)
  description = "Additional labels to add to everything"
  default     = {}
}
