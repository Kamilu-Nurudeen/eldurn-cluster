# Karpenter Terraform Module

## Overview

This module deploys Karpenter, a Kubernetes autoscaler that automatically provisions the right compute resources to handle your cluster's applications. It leverages the official `terraform-aws-modules/eks/aws//modules/karpenter` module and adds custom Helm chart deployment with configurable IAM roles, service accounts, and spot instance termination handling.

## Features

- **Karpenter Controller**: Deploys Karpenter controller with configurable replicas, resources, and scheduling.
- **IAM Roles**: Creates IAM roles for both Karpenter controller (IRSA) and nodes with proper permissions.
- **Spot Instance Support**: Configures SQS queue and EventBridge rules for native spot termination handling.
- **Helm Charts**: Installs Karpenter and Karpenter CRDs via Helm with customizable values.
- **Security**: Supports IRSA (IAM Roles for Service Accounts) and Pod Identity for secure AWS resource access.
- **Monitoring**: Optional ServiceMonitor for Prometheus monitoring integration.
- **Customization**: Extensive configuration options for resources, scheduling, and deployment settings.

## Usage

```hcl
module "karpenter" {
  source = "./modules/karpenter"

  cluster_name    = "my-eks-cluster"
  cluster_endpoint = "https://my-cluster.eks.amazonaws.com"
  oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/EXAMPLE"
  
  # Optional: Customize Karpenter settings
  replicas = 2
  log_level = "info"
  
  # Optional: Enable spot termination handling
  enable_spot_termination = true
  
  tags = { Environment = "production" }
}
```

## Inputs

### Core Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_name` | Name of the EKS cluster | `string` | n/a | yes |
| `cluster_endpoint` | EKS cluster API server endpoint | `string` | n/a | yes |
| `oidc_provider_arn` | OIDC provider ARN from the EKS module | `string` | n/a | yes |

### Helm Chart Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `karpenter_chart_enabled` | Enable/disable Karpenter Helm chart installation | `bool` | `true` | no |
| `karpenter_crd_chart_enabled` | Enable/disable Karpenter CRDs Helm chart installation | `bool` | `true` | no |
| `karpenter_chart_v` | Karpenter Helm chart version | `string` | `"1.6.0"` | no |
| `karpenter_chart_registry` | Karpenter Helm chart registry | `string` | `"oci://public.ecr.aws/karpenter/karpenter"` | no |
| `karpenter_crd_chart_v` | Karpenter CRDs Helm chart version | `string` | `"1.6.0"` | no |
| `karpenter_crd_chart_registry` | Karpenter CRDs Helm chart registry | `string` | `"oci://public.ecr.aws/karpenter/karpenter-crd"` | no |
| `karpenter_override_values_file` | Path to custom values file for Karpenter | `string` | `null` | no |

### Controller Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `replicas` | Number of Karpenter controller replicas | `number` | `2` | no |
| `node_selector` | Node selectors for pod scheduling | `map(string)` | `{"kubernetes.io/os" = "linux"}` | no |
| `affinity` | Pod affinity rules | `map(any)` | `{}` | no |
| `controller_resources` | CPU and memory resources for controller | `map(object({cpu = string, memory = string}))` | See variables.tf | no |
| `log_level` | Log level for Karpenter controller | `string` | `"debug"` | no |

### IAM Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enable_irsa` | Enable IRSA for Karpenter controller | `bool` | `true` | no |
| `enable_v1_permissions` | Enable v1+ permissions (vs v0.33.x-v0.37.x) | `bool` | `true` | no |
| `enable_pod_identity` | Enable pod identity for Karpenter controller | `bool` | `true` | no |
| `create_pod_identity_association` | Create pod identity association | `bool` | `false` | no |
| `iam_role_path` | IAM role path | `string` | `"/"` | no |
| `iam_role_policies` | Additional IAM policies to attach | `map(string)` | `{}` | no |

### Node IAM Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `create_access_entry` | Create access entry for node IAM role | `bool` | `false` | no |
| `access_entry_type` | Type of access entry | `string` | `"EC2_LINUX"` | no |
| `node_iam_role_attach_cni_policy` | Attach CNI policy to node IAM role | `bool` | `true` | no |
| `node_iam_role_additional_policies` | Additional policies for node IAM role | `map(string)` | `{}` | no |

### Spot Instance Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `enable_spot_termination` | Enable native spot termination handling | `bool` | `true` | no |

### Monitoring and Metadata

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `service_monitor_enabled` | Enable ServiceMonitor for Prometheus | `bool` | `false` | no |
| `service_account_annotations` | Service account annotations | `map(string)` | `{}` | no |
| `pod_labels` | Pod labels | `map(string)` | `{}` | no |
| `pod_annotations` | Pod annotations | `map(string)` | `{}` | no |
| `tags` | Tags to apply to AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `karpenter_nodes_iam_role_arn` | ARN of the IAM role for Karpenter nodes |
| `karpenter_nodes_iam_role_name` | Name of the IAM role for Karpenter nodes |
| `karpenter_nodes_instance_profile_arn` | ARN of the instance profile for Karpenter nodes |
| `karpenter_controller_iam_role_arn` | ARN of the IAM role used by Karpenter controller |
| `karpenter_interaptions_queue_arn` | ARN of the SQS queue for spot instance interruptions |
| `karpenter_interaptions_queue_name` | Name of the SQS queue for spot instance interruptions |

## IAM Roles and Permissions

### Controller IAM Role

The module creates an IAM role for the Karpenter controller with the following capabilities:

- **IRSA Support**: Uses IAM Roles for Service Accounts for secure AWS access
- **Pod Identity**: Supports EKS Pod Identity for alternative authentication
- **Spot Termination**: Permissions for SQS and EventBridge spot termination handling
- **Node Provisioning**: Permissions to create and manage EC2 instances
- **Custom Policies**: Support for additional IAM policies via `iam_role_policies`

### Node IAM Role

Creates an IAM role for nodes provisioned by Karpenter:

- **CNI Policy**: Automatically attaches Amazon EKS CNI policy
- **Additional Policies**: Support for custom policies via `node_iam_role_additional_policies`
- **Access Entry**: Optional EKS access entry creation for the role

## Spot Instance Handling

When `enable_spot_termination = true`, the module creates:

- **SQS Queue**: For receiving spot instance interruption notifications
- **EventBridge Rules**: To route spot termination events to the SQS queue
- **Controller Configuration**: Configures Karpenter to use the interruption queue

## Helm Chart Configuration

### Karpenter Controller

The Karpenter controller is deployed with the following default configuration:

```yaml
settings:
  clusterName: <cluster_name>
  clusterEndpoint: <cluster_endpoint>
  interruptionQueue: <sqs_queue_name>  # if enabled

replicas: 2
nodeSelector:
  kubernetes.io/os: linux

serviceAccount:
  create: true
  name: karpenter
  annotations: {}  # IRSA annotations added automatically

controller:
  resources:
    requests:
      cpu: "1"
      memory: "2Gi"
    limits:
      cpu: "1"
      memory: "2Gi"

logLevel: debug
priorityClassName: system-cluster-critical
```

### Custom Values

You can provide custom Helm values via:

1. **Variables**: Use `controller_resources`, `replicas`, `log_level`, etc.
2. **Values File**: Use `karpenter_override_values_file` for complex configurations

## Monitoring

### ServiceMonitor

Enable Prometheus monitoring by setting:

```hcl
service_monitor_enabled = true
```

This creates a ServiceMonitor resource for Karpenter metrics.

## Security Features

### IRSA (IAM Roles for Service Accounts)

- Automatically configures IRSA annotations for the Karpenter service account
- Uses the OIDC provider from the EKS cluster
- Supports v1+ permissions for enhanced security

### Pod Identity

- Alternative to IRSA for EKS Pod Identity
- Configured via `enable_pod_identity` and `create_pod_identity_association`

## Resource Requirements

### Default Resources

- **CPU**: 1 core (requests and limits)
- **Memory**: 2Gi (requests and limits)
- **Replicas**: 2 for high availability

### Customization

```hcl
controller_resources = {
  requests = {
    cpu    = "500m"
    memory = "1Gi"
  }
  limits = {
    cpu    = "1000m"
    memory = "2Gi"
  }
}
```

## Dependencies

This module depends on:

- **EKS Cluster**: Must be deployed and accessible
- **OIDC Provider**: Requires OIDC provider ARN from EKS module
- **Kubernetes Provider**: Terraform Kubernetes provider must be configured

## Notes

- The module creates a dedicated namespace (`karpenter`) for Karpenter resources
- CRDs are installed separately from the main chart for better control
- Spot termination handling requires EventBridge and SQS permissions
- The controller uses `system-cluster-critical` priority class
- Service account annotations are automatically configured for IRSA when enabled

---

_See `variables.tf` for all configurable options._ 
