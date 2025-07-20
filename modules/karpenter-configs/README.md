# Karpenter Provisioner Terraform Module

## Overview

This module manages Karpenter EC2NodeClass and NodePool resources for EKS clusters. It provides a flexible and scalable way to define multiple node classes and node pools with different configurations, instance types, and requirements. The module uses `kubernetes_manifest` resources to create Kubernetes custom resources directly.

## Features

- **Multiple EC2NodeClass Support**: Create multiple EC2NodeClass resources with different configurations
- **Multiple NodePool Support**: Create multiple NodePool resources with different requirements and limits
- **Flexible Configuration**: Extensive customization options for instance types, capacity types, and node requirements
- **Default Values**: Sensible defaults for common configurations
- **Tag Management**: Automatic tag propagation to EC2 instances
- **Security**: Support for custom security groups and subnet selectors
- **Cost Optimization**: Built-in support for spot instances and consolidation policies

## Usage

### Basic Example

```hcl
module "karpenter_provisioner" {
  source = "./modules/karpenter-provisioner"

  cluster_name = "my-eks-cluster"
  karpenter_nodes_iam_role_name = "KarpenterNodes-my-eks-cluster"
  karpenter_dependency = module.karpenter

  # Define EC2NodeClass resources
  ec2_nodeclasses = {
    "default" = {
      instance_types = ["m5.large", "m5a.large", "m5d.large"]
      capacity_type = "spot"
      ami_family = "AL2"
    }
    "gpu" = {
      instance_types = ["g4dn.xlarge", "g5.xlarge"]
      capacity_type = "on-demand"
      ami_family = "AL2"
      tags = {
        "node-type" = "gpu"
      }
    }
  }

  # Define NodePool resources
  nodepools = {
    "default" = {
      node_class_ref = "default"
      requirements = [
        {
          key = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values = ["c", "m", "r"]
        },
        {
          key = "kubernetes.io/arch"
          operator = "In"
          values = ["amd64"]
        }
      ]
      limits = {
        cpu = "1000"
        memory = "1000Gi"
      }
    }
    "gpu" = {
      node_class_ref = "gpu"
      requirements = [
        {
          key = "node.kubernetes.io/instance-type"
          operator = "In"
          values = ["g4dn.xlarge", "g5.xlarge"]
        }
      ]
      limits = {
        cpu = "100"
        memory = "100Gi"
      }
    }
  }

  default_tags = {
    Environment = "production"
    ManagedBy = "terraform"
  }
}
```

### Advanced Example

```hcl
module "karpenter_provisioner" {
  source = "./modules/karpenter-provisioner"

  cluster_name = "my-eks-cluster"
  karpenter_nodes_iam_role_name = "KarpenterNodes-my-eks-cluster"
  karpenter_dependency = module.karpenter

  ec2_nodeclasses = {
    "high-memory" = {
      instance_types = ["r5.2xlarge", "r5a.2xlarge", "r5d.2xlarge"]
      capacity_type = "spot"
      ami_family = "AL2"
      block_device_mappings = [
        {
          deviceName = "/dev/xvda"
          ebs = {
            volumeSize = "100Gi"
            volumeType = "gp3"
            deleteOnTermination = true
            encrypted = true
            iops = 3000
            throughput = 125
          }
        }
      ]
      subnet_selector_terms = [
        {
          tags = {
            "kubernetes.io/role" = "node"
            "subnet-type" = "private"
          }
        }
      ]
      security_group_selector_terms = [
        {
          tags = {
            "kubernetes.io/cluster/my-eks-cluster" = "owned"
            "security-group-type" = "node"
          }
        }
      ]
      user_data = base64encode(<<-EOF
        #!/bin/bash
        echo "Custom user data for high-memory nodes"
      EOF
      )
      tags = {
        "node-type" = "high-memory"
        "workload" = "memory-intensive"
      }
    }
  }

  nodepools = {
    "high-memory" = {
      node_class_ref = "high-memory"
      requirements = [
        {
          key = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values = ["r"]
        },
        {
          key = "karpenter.k8s.aws/instance-generation"
          operator = "Gt"
          values = ["4"]
        },
        {
          key = "kubernetes.io/arch"
          operator = "In"
          values = ["amd64"]
        }
      ]
      startup_taints = [
        {
          key = "node-type"
          value = "high-memory"
          effect = "NoSchedule"
        }
      ]
      kubelet = {
        "maxPods" = "110"
        "systemReserved" = {
          "cpu" = "100m"
          "memory" = "100Mi"
        }
        "kubeReserved" = {
          "cpu" = "100m"
          "memory" = "100Mi"
        }
      }
      limits = {
        cpu = "200"
        memory = "200Gi"
      }
      weight = 2
      disruption = {
        consolidation_policy = "WhenEmpty"
        consolidation_ttl = "60s"
        consolidate_after = "30s"
      }
      template = {
        metadata = {
          labels = {
            "node-type" = "high-memory"
            "workload" = "memory-intensive"
          }
          annotations = {
            "node.alpha.kubernetes.io/ttl" = "0"
          }
        }
      }
    }
  }

  default_annotations = {
    "karpenter.sh/do-not-evict" = "true"
  }

  default_labels = {
    "managed-by" = "karpenter"
  }

  default_tags = {
    Environment = "production"
    ManagedBy = "terraform"
    Owner = "platform-team"
  }
}
```

## Inputs

### Core Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_name` | Name of the EKS cluster | `string` | n/a | yes |
| `karpenter_nodes_iam_role_name` | Name of the IAM role for Karpenter nodes | `string` | n/a | yes |
| `karpenter_dependency` | Dependency on Karpenter module | `any` | `null` | no |

### Default Values

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `default_annotations` | Default annotations for all resources | `map(string)` | `{}` | no |
| `default_labels` | Default labels for all resources | `map(string)` | `{}` | no |
| `default_tags` | Default tags for EC2 instances | `map(string)` | `{}` | no |

### EC2NodeClass Configuration

The `ec2_nodeclasses` variable accepts a map of EC2NodeClass configurations with the following structure:

```hcl
ec2_nodeclasses = {
  "nodeclass-name" = {
    ami_family = optional(string)                    # Default: "AL2"
    capacity_type = optional(string)                 # Default: "spot"
    architecture = optional(string)                  # Default: "x86_64"
    instance_types = optional(list(string))          # Default: ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
    subnet_selector_terms = optional(list(object))   # Default: kubernetes.io/role=node
    security_group_selector_terms = optional(list(object)) # Default: kubernetes.io/cluster/<cluster_name>=owned
    block_device_mappings = optional(list(object))   # Default: 20Gi gp3 encrypted volume
    user_data = optional(string)                     # Default: null
    tags = optional(map(string))                     # Default: {}
    annotations = optional(map(string))              # Default: {}
    labels = optional(map(string))                   # Default: {}
  }
}
```

### NodePool Configuration

The `nodepools` variable accepts a map of NodePool configurations with the following structure:

```hcl
nodepools = {
  "nodepool-name" = {
    node_class_ref = optional(string)                # Default: nodepool name
    requirements = optional(list(object))            # Default: standard requirements
    startup_taints = optional(list(object))         # Default: []
    kubelet = optional(map(any))                    # Default: {}
    limits = optional(object)                        # Default: {cpu = "1000", memory = "1000Gi"}
    weight = optional(number)                        # Default: 1
    disruption = optional(object)                    # Default: standard disruption settings
    template = optional(object)                      # Default: {}
    annotations = optional(map(string))              # Default: {}
    labels = optional(map(string))                   # Default: {}
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `ec2_nodeclass_names` | List of created EC2NodeClass resource names |
| `nodepool_names` | List of created NodePool resource names |
| `ec2_nodeclass_resources` | Map of EC2NodeClass resource configurations |
| `nodepool_resources` | Map of NodePool resource configurations |

## EC2NodeClass Features

### Instance Configuration
- **AMI Family**: Support for AL2, AL2023, Bottlerocket, Ubuntu
- **Instance Types**: Flexible instance type selection
- **Capacity Type**: Spot, on-demand, or mixed
- **Architecture**: x86_64, arm64

### Storage Configuration
- **Block Device Mappings**: Custom EBS volume configurations
- **Volume Types**: gp2, gp3, io1, io2
- **Encryption**: Automatic EBS encryption
- **IOPS and Throughput**: Configurable for gp3 and io1/io2

### Networking Configuration
- **Subnet Selection**: Tag-based subnet selection
- **Security Groups**: Tag-based security group selection
- **User Data**: Custom initialization scripts

## NodePool Features

### Node Requirements
- **Instance Categories**: c, m, r, g, p, inf, trn
- **Instance Generations**: Generation-based filtering
- **Architecture**: amd64, arm64
- **Operating System**: linux, windows
- **Capacity Type**: spot, on-demand

### Scheduling Configuration
- **Startup Taints**: Node taints for workload isolation
- **Kubelet Configuration**: Custom kubelet settings
- **Resource Limits**: CPU and memory limits
- **Weight**: Priority for node selection

### Disruption Management
- **Consolidation Policy**: WhenEmpty, WhenUnderutilized
- **Consolidation TTL**: Time before consolidation
- **Consolidate After**: Time before consolidation starts

## Best Practices

### Cost Optimization
1. **Use Spot Instances**: Configure `capacity_type = "spot"` for cost savings
2. **Instance Diversity**: Include multiple instance types for better availability
3. **Consolidation**: Enable consolidation to reduce idle nodes

### Performance
1. **Instance Selection**: Choose appropriate instance types for workloads
2. **Resource Limits**: Set appropriate CPU and memory limits
3. **Kubelet Tuning**: Configure kubelet for optimal performance

### Security
1. **Encryption**: Enable EBS encryption for data security
2. **Security Groups**: Use dedicated security groups for nodes
3. **IAM Roles**: Ensure proper IAM role permissions

### Reliability
1. **Multiple AZs**: Use subnets across multiple availability zones
2. **Instance Diversity**: Include multiple instance families
3. **Graceful Shutdown**: Configure proper consolidation policies

## Dependencies

This module depends on:
- **Karpenter Module**: Must be deployed before this module
- **EKS Cluster**: Must be accessible via kubectl
- **IAM Role**: Karpenter nodes IAM role must exist

## Notes

- The module uses `kubernetes_manifest` to create Kubernetes resources
- EC2NodeClass and NodePool resources are created with proper dependencies
- Default values provide sensible configurations for most use cases
- Custom configurations override defaults as needed
- Tags and labels are automatically merged with defaults

---

_See `variables.tf` for all configurable options._ 
