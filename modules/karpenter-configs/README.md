# Karpenter Configs Terraform Module

## Overview

This module manages Karpenter EC2NodeClass and NodePool resources for EKS clusters using the `kubernetes_manifest` resource. It enables flexible, declarative configuration of node classes and node pools for dynamic, cost-optimized, and scalable EKS node provisioning.

## Features

- Declarative creation of multiple EC2NodeClass and NodePool resources
- Flexible configuration for AMI family, block devices, tags, and user data
- Default values for common settings (AMI family, block device, etc.)
- Tag, label, and annotation merging for all resources
- Support for custom requirements, disruption policies, and template metadata
- Sensible defaults for consolidation and node selection

## Usage Example

```hcl
module "karpenter_configs" {
  source = "./modules/karpenter-configs"

  cluster_name = "my-eks-cluster"
  karpenter_nodes_iam_role_name = "KarpenterNodes-my-eks-cluster"
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]

  ec2_nodeclasses = {
    "default" = {
      ami_family = "AL2023"
      tags = {
        "env" = "test"
      }
    }
  }

  nodepools = {
    "default" = {
      requirements = [
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
        }
      ]
    }
  }

  default_tags = {
    managed_by = "karpenter"
  }
}
```

## Input Variables

| Name                         | Description                                              | Type         | Default      | Required |
|------------------------------|----------------------------------------------------------|--------------|--------------|:--------:|
| `cluster_name`               | Name of the EKS cluster                                  | string       | n/a          |   yes    |
| `karpenter_nodes_iam_role_name` | Name of the IAM role for Karpenter nodes               | string       | n/a          |   yes    |
| `availability_zones`         | List of availability zones for the region                | list(string) | n/a          |   yes    |
| `default_annotations`        | Default annotations for all resources                    | map(string)  | `{}`         |    no    |
| `default_labels`             | Default labels for all resources                         | map(string)  | `{}`         |    no    |
| `default_tags`               | Default tags for EC2 instances                           | map(string)  | `{ managed_by = "karpenter" }` | no |
| `associate_public_ip_address`| Whether to associate public IP addresses to EC2 instances| bool         | `false`      |    no    |
| `ec2_nodeclasses`            | Map of EC2NodeClass configurations                       | map(object)  | `{}`         |    no    |
| `nodepools`                  | Map of NodePool configurations                           | map(object)  | `{}`         |    no    |

### EC2NodeClass Configuration

Each entry in `ec2_nodeclasses` supports:
- `ami_family` (string, optional)
- `associate_public_ip_address` (bool, optional)
- `ami_selector_alias` (string, optional)
- `block_device_mappings` (list(object), optional)
- `user_data` (string, optional)
- `tags` (map(string), optional)
- `annotations` (map(string), optional)
- `labels` (map(string), optional)

### NodePool Configuration

Each entry in `nodepools` supports:
- `node_class_ref` (string, optional)
- `requirements` (list(object), optional)
- `weight` (number, optional)
- `disruption` (object, optional)
- `template` (object, optional)
- `annotations` (map(string), optional)
- `labels` (map(string), optional)

See `variables.tf` for the full schema and all options.

## Outputs

| Name                    | Description                                 |
|-------------------------|---------------------------------------------|
| `ec2_nodeclass_names`   | Names of the created EC2NodeClass resources |
| `nodepool_names`        | Names of the created NodePool resources     |
| `ec2_nodeclass_resources` | Map of EC2NodeClass resource configurations |
| `nodepool_resources`    | Map of NodePool resource configurations     |

## Notes

- Uses `kubernetes_manifest` to create Karpenter custom resources.
- Default values are provided for most fields; override as needed.
- All tags, labels, and annotations are merged with defaults.
- See `main.tf` and `variables.tf` for implementation details and advanced configuration. 
