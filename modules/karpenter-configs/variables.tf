variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "karpenter_nodes_iam_role_name" {
  description = "Name of the IAM role for Karpenter nodes"
  type        = string
}

variable "default_annotations" {
  description = "Default annotations to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "default_labels" {
  description = "Default labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "default_tags" {
  description = "Default tags to apply to EC2 instances"
  type        = map(string)
  default = {
    managed_by = "karpenter"
  }
}
variable "associate_public_ip_address" {
  description = "Whether to associate public IP addresses to EC2 instances"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of availability zones for the region"
  type        = list(string)
}
# EC2NodeClass Configuration
variable "ec2_nodeclasses" {
  description = "Map of EC2NodeClass configurations"
  type = map(object({
    ami_family                  = optional(string)
    associate_public_ip_address = optional(bool)
    ami_selector_alias          = optional(string)
    block_device_mappings = optional(list(object({
      deviceName = string
      ebs = object({
        volumeSize          = string
        volumeType          = string
        deleteOnTermination = bool
        encrypted           = bool
        iops                = optional(number)
        throughput          = optional(number)
      })
    })))
    user_data   = optional(string)
    tags        = optional(map(string))
    annotations = optional(map(string))
    labels      = optional(map(string))
  }))
  default = {}
}

# NodePool Configuration
variable "nodepools" {
  description = "Map of NodePool configurations"
  type = map(object({
    node_class_ref = optional(string)
    requirements = optional(list(object({
      key      = string
      operator = string
      values   = list(string)
    })))
    weight = optional(number)
    disruption = optional(object({
      consolidation_policy = optional(string)
      consolidate_after    = optional(string)
      budgets = optional(list(object({
        nodes     = string
        reasons   = optional(list(string))
        schedule  = optional(string)
        duration  = optional(string)
      })))
      availability_zones   = optional(list(string))
    }))
    template = optional(object({
      metadata = optional(object({
        annotations = optional(map(string))
        labels      = optional(map(string))
      }))
    }))
    annotations = optional(map(string))
    labels      = optional(map(string))
  }))
  default = {}
}
