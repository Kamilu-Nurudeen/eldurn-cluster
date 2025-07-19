variable "account_id" {
  type        = string
  description = "The AWS sub-account ID cluster will be placed into"
}

variable "aws_region" {
  type        = string
  description = "EKS cluster region"
  default     = "eu-north-1"
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default = {
    create = "30m"
    update = "60m"
    delete = "15m"
  }
}

variable "node_group_timeouts" {
  description = "Create, update, and delete timeout configurations for the node group"
  type        = map(string)
  default = {
    create = "60m"
    update = "360m"
    delete = "60m"
  }
}

variable "environment" {
  type        = string
  description = "environment"
  default     = "testing"
}

variable "tags" {
  type        = map(string)
  description = "tags"
}

variable "add_cluster_tag" {
  type        = bool
  description = "Add `cluster = cluster_name` tag to EKS module."
  default     = true
}

variable "cluster_addon_coredns_version" {
  type        = string
  description = "Coredns addon version"
  default     = "v1.12.2-eksbuild.4"
}

variable "cluster_addon_kube_proxy_version" {
  type        = string
  description = "Kube Proxy addon version"
  default     = "v1.33.0-eksbuild.2"
}

variable "vpc_cni_addon_version" {
  type    = string
  default = "v1.19.6-eksbuild.7"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes cluster version"
  default     = "1.33"
}

variable "private_subnets" {
  type        = list(string)
  description = "EKS CLuster Private subnets to attach EKS cluster to (excluding rfc6598)"
}

variable "region" {
  type        = string
  description = "Region EKS is being deployed into"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to place cluster into"
}

variable "worker_default_size" {
  type        = string
  description = "Default instance type for workers"
  default     = "c5.4xlarge"
}

variable "default-node-group" {
  type = any
  default = {
    min_size     = 1
    max_size     = 2
    desired_size = 1
    update_config = {
      max_unavailable_percentage = 10
    }
    instance_types        = ["r5b.2xlarge"]
    create_security_group = false
    iam_role_additional_policies = {
      "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 100
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          encrypted             = false
          delete_on_termination = true
        }
      }
    }
    labels = {
      "node-group" = "default"
    }

  }
}

variable "assume_role_name" {
  type        = string
  description = "The name of the role to assume for the EKS cluster"
  default     = "platform-bot"

}

variable "cluster_service_cidr" {
  type        = string
  description = "The CIDR block for the Kubernetes service network. This is used to allocate service IPs."
  default     = "172.20.0.0/16" # Default CIDR for ipV4 services
}

variable "rfc6598_subnet_ids" {
  type        = list(string)
  description = "List of RFC6598 subnet IDs to use for ENIConfig."
}
