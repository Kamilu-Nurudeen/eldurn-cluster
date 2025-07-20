variable "karpenter_chart_enabled" {
  description = "Used to install or uninstall karpenter helm release"
  type        = bool
  default     = true
}

variable "karpenter_crd_chart_enabled" {
  description = "Used to install or uninstall karpenter crd helm release"
  type        = bool
  default     = true
}

variable "karpenter_chart_v" {
  type    = string
  default = "1.6.0"
}

variable "karpenter_chart_registry" {
  type    = string
  default = "oci://public.ecr.aws/karpenter/karpenter"
}

variable "karpenter_crd_chart_v" {
  description = "Karpenter CRDs Helm chart version. By default equals var.karpenter_chart_v"
  type        = string
  default     = "1.6.0"
}

variable "karpenter_crd_chart_registry" {
  type    = string
  default = "oci://public.ecr.aws/karpenter/karpenter-crd"
}

variable "tags" {
  description = "A map of additional tags to add to AWS resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Karpenter Controller Helm Chart configuration
################################################################################
variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "replicas" {
  description = "Number of Karpenter controller replicas"
  type        = number
  default     = 2
}

variable "node_selector" {
  description = "Node selectors to schedule the pod to nodes with labels."
  type        = map(string)
  default = {
    "kubernetes.io/os" : "linux"
  }
}

variable "affinity" {
  description = "Affinity rules for scheduling the pod. If an explicit label selector is not provided for pod affinity or pod anti-affinity one will be created from the pod selector labels."
  type        = map(any)
  default     = {}
}

variable "service_account_annotations" {
  description = "Karpenter Controller Service account annotations. IRSA annotation added automatically if enabled."
  type        = map(string)
  default     = {}
}

variable "pod_labels" {
  description = "Pod labels"
  type        = map(string)
  default     = {}
}

variable "pod_annotations" {
  description = "Pod annotations"
  type        = map(string)
  default     = {}
}

variable "log_level" {
  type    = string
  default = "debug"
}

variable "service_monitor_enabled" {
  type    = bool
  default = false
}

variable "controller_resources" {
  description = "Karpenter controller resources. Set using this var or using values override file. Using this tf var requires setting both `cpu` and `memory` for either `requests` or `limits` or both."
  type = map(object({
    cpu    = string
    memory = string
  }))
  default = {
    requests = {
      cpu    = "1"
      memory = "2Gi"
    }
    limits = {
      cpu    = "1"
      memory = "2Gi"
    }
  }
}

variable "karpenter_override_values_file" {
  description = "Karpenter Helm Release values file. Should be a valid YAML file."
  type        = string
  default     = null
}


################################################################################
# Karpenter Controller IAM Role
################################################################################
variable "enable_irsa" {
  description = "Enable IRSA for the Karpenter controller"
  type        = bool
  default     = true
}

variable "enable_v1_permissions" {
  description = "Determines whether to enable permissions suitable for v1+ (`true`) or for v0.33.x-v0.37.x (`false`)"
  type        = bool
  default     = true
}

variable "enable_pod_identity" {
  description = "Enable pod identity for the Karpenter controller"
  type        = bool
  default     = true
}

variable "create_pod_identity_association" {
  description = "Determines whether to create pod identity association"
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "value of the `oidc_provider_arn` output from the EKS module"
  type        = string
}

variable "iam_role_path" {
  description = "Karpenter Conroller - IAM role path"
  type        = string
  default     = "/"
}

variable "iam_role_policies" {
  description = "Karpenter Controller - Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

################################################################################
# Karpenter Nodes IAM Role
################################################################################
variable "create_access_entry" {
  description = "Determines whether an access entry is created for the IAM role used by the node IAM role"
  type        = bool
  default     = true
}

variable "access_entry_type" {
  description = "Type of the access entry. `EC2_LINUX`, `FARGATE_LINUX`, or `EC2_WINDOWS`; defaults to `EC2_LINUX`"
  type        = string
  default     = "EC2_LINUX"
}

variable "node_iam_role_attach_cni_policy" {
  description = "Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "enable_spot_termination" {
  description = "enable_spot_termination	Determines whether to enable native spot termination handling. Creates SQS and EventBridge rules"
  type        = bool
  default     = true
}
