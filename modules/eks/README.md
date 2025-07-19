# EKS Terraform Module

## Overview

This module provisions an Amazon EKS (Elastic Kubernetes Service) cluster with managed node groups, secure networking, IAM roles, and essential Kubernetes add-ons. It leverages the official `terraform-aws-modules/eks/aws` module, adding custom security, encryption, and access management for production-ready Kubernetes clusters on AWS.

## Features

- **EKS Cluster Creation**: Deploys a fully managed EKS cluster with configurable Kubernetes version.
- **Managed Node Groups**: Supports managed node groups with custom instance types, scaling, and labels.
- **Security**: Creates additional security groups, custom ingress/egress rules, and enables encryption with a dedicated KMS key.
- **Add-ons**: Installs and manages core Kubernetes add-ons (CoreDNS, kube-proxy, VPC CNI) with version control and custom networking configuration.
- **VPC CNI Custom Networking**: Configures VPC CNI with custom networking, prefix delegation, and ENI configuration for RFC6598 subnets.
- **Logging**: Enables control plane logging for audit, API, scheduler, and more.
- **IAM & Access**: Configures access entries and policies for admins and developers, including IRSA support.
- **Private Networking**: Supports private subnets and internal endpoint access.
- **Session Manager**: Pre-installs and configures AWS Systems Manager Session Manager on worker nodes.

## Usage

```hcl
module "eks" {
  source  = "./modules/eks"

  account_id      = var.account_id
  aws_region      = var.aws_region
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.33"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  rfc6598_subnet_ids = module.vpc.rfc6598_subnet_ids
  tags            = { Environment = "testing" }
  # ...other variables as needed
}
```

## Inputs

| Name                        | Description                                              | Type          | Default                        | Required |
|-----------------------------|----------------------------------------------------------|---------------|--------------------------------|:--------:|
| account_id                  | AWS account ID                                           | `string`      | n/a                            | yes      |
| aws_region                  | AWS region for EKS                                       | `string`      | `eu-north-1`                   | no       |
| cluster_name                | Name of the EKS cluster                                  | `string`      | n/a                            | yes      |
| cluster_version             | Kubernetes version                                       | `string`      | `1.33`                         | no       |
| vpc_id                      | VPC ID for the cluster                                   | `string`      | n/a                            | yes      |
| private_subnets             | List of private subnet IDs                               | `list(string)`| n/a                            | yes      |
| rfc6598_subnet_ids         | List of RFC6598 subnet IDs for VPC CNI ENI config       | `list(string)`| n/a                            | yes      |
| tags                        | Tags to apply to resources                               | `map(string)` | `{}`                           | no       |
| worker_default_size         | Default instance type for workers                        | `string`      | `c5.4xlarge`                   | no       |
| default-node-group          | Node group configuration                                 | `any`         | See `variables.tf`             | no       |
| add_cluster_tag             | Add `cluster = cluster_name` tag                         | `bool`        | `true`                         | no       |
| cluster_addon_coredns_version| CoreDNS addon version                                   | `string`      | `v1.12.2-eksbuild.4`           | no       |
| cluster_addon_kube_proxy_version| Kube Proxy addon version                              | `string`      | `v1.33.0-eksbuild.2`           | no       |
| vpc_cni_addon_version       | VPC CNI addon version                                   | `string`      | `v1.19.6-eksbuild.7`           | no       |
| cluster_timeouts            | Cluster create/update/delete timeouts                    | `map(string)` | `{create="30m",...}`         | no       |
| node_group_timeouts         | Node group create/update/delete timeouts                 | `map(string)` | `{create="60m",...}`         | no       |
| assume_role_name            | Name of the role to assume for the EKS cluster           | `string`      | `platform-bot`                 | no       |
| cluster_service_cidr        | Kubernetes service CIDR block                            | `string`      | `172.20.0.0/16`                | no       |
| environment                 | Environment name                                        | `string`      | `testing`                      | no       |
| region                      | Region EKS is being deployed into                        | `string`      | n/a                            | yes      |

## Outputs

| Name                          | Description                                 |
|-------------------------------|---------------------------------------------|
| cluster_id                    | EKS cluster ID                              |
| cluster_endpoint              | EKS API server endpoint                     |
| cluster_oidc_issuer_url       | OIDC issuer URL for the cluster             |
| oidc_provider_arn             | OIDC provider ARN                           |
| cluster_ca_certificate        | Cluster CA certificate                      |
| cluster_primary_security_group_id | Primary security group for the cluster   |
| node_security_group_id        | Node group security group ID                |
| eks_managed_node_groups       | Managed node group details                  |

## Access Management

### Initial Cluster Access

The module configures two initial access entries:

1. **Candidate Admin**: IAM user with cluster admin access
   ```hcl
   candidate_admin = {
     principal_arn = "arn:aws:iam::${var.account_id}:user/candidate"
     policy_associations = {
       admin = {
         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
         access_scope = { type = "cluster" }
       }
     }
   }
   ```

2. **Platform Bot**: IAM role with cluster admin access
   ```hcl
   platform_bot = {
     principal_arn = "arn:aws:iam::${var.account_id}:role/${var.assume_role_name}"
     policy_associations = {
       admin = {
         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
         access_scope = { type = "cluster" }
       }
     }
   }
   ```

### Additional Access Roles

- **Developer Access**: Adds developers to EKS access using IAM role and associates the `AmazonEKSViewPolicy` (see `clusterroles.tf`).

## VPC CNI Configuration

The module configures VPC CNI with custom networking features:

### Environment Variables
- `AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"`: Enables custom networking
- `ENI_CONFIG_LABEL_DEF = "failure-domain.beta.kubernetes.io/zone"`: Sets ENI config label
- `ENABLE_PREFIX_DELEGATION = "true"`: Enables prefix delegation for more IP addresses
- `WARM_PREFIX_TARGET = "1"`: Sets warm prefix target

### ENI Configuration
- Creates ENI configs for RFC6598 subnets
- Maps subnets to availability zones automatically
- Associates node security groups with ENI configs

## Security Features

### Security Groups
- **Additional Security Group**: Allows internal EKS endpoint access (443) from 10.0.0.0/8
- **Node Security Group**: Custom ingress/egress rules for:
  - Envoy ports (15000-15090)
  - AWS Load Balancer Controller (9443)
  - Metrics Server (10250)
  - API Webhooks (443)
  - Internal cluster communication

### Encryption
- **KMS Key**: Dedicated KMS key for EKS secrets encryption
- **Key Rotation**: Enabled with 7-day deletion window

## Node Group Configuration

### Default Settings
- **Instance Type**: `r5b.2xlarge` (configurable)
- **Disk Size**: 100GB GP3 with 3000 IOPS
- **Scaling**: 1-2 nodes with 10% max unavailable during updates
- **Labels**: `node-group = default`

### Session Manager
Pre-installs AWS Systems Manager Session Manager on worker nodes for secure access.

## Add-ons

### CoreDNS
- Version: `v1.12.2-eksbuild.4` (configurable)
- Conflict resolution: `OVERWRITE`

### Kube-Proxy
- Version: `v1.33.0-eksbuild.2` (configurable)
- Conflict resolution: `OVERWRITE`

### VPC CNI
- Version: `v1.19.6-eksbuild.7` (configurable)
- Custom networking configuration
- ENI configs for RFC6598 subnets
- Prefix delegation enabled

## Notes

- The module creates a KMS key for secret encryption.
- Security groups and rules are tailored for EKS best practices.
- Add-on versions and node group settings are configurable via variables.
- VPC CNI is configured with custom networking for RFC6598 subnets.
- Session Manager is pre-installed on worker nodes for secure access.

---

_See `variables.tf` for all configurable options._ 
