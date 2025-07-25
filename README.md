# eldurn-cluster
The Terraform/Terragrunt Repository for Managing Eldurn EKS clusters' Infrastructure

## Overview

This repository contains Terraform modules and Terragrunt configurations for managing AWS infrastructure, including EKS clusters, VPC networking, and supporting services for the Eldurn platform.

## Architecture

```
eldurn-cluster/
├── README.md               # Repository documentation
├── root.hcl                # Root Terragrunt configuration file
├── common/                 # Shared Terragrunt configuration files for modules and environments
├── modules/
│   ├── eks/                 # EKS cluster with managed node groups
│   ├── vpc/                 # VPC with public/private subnets
│   ├── vpc_eks_private/     # Private VPC for EKS clusters
│   ├── argo-rollout/        # Argo Rollouts controller deployment
│   ├── eks_cluster_charts/  # Helm charts for EKS cluster add-ons
│   ├── karpenter/           # Karpenter autoscaler deployment
│   ├── karpenter-configs/   # Karpenter configuration resources
│   ├── metric-server/       # Kubernetes metrics server deployment
│   ├── ebs-csi-driver/      # EBS CSI driver for dynamic volume provisioning
│   └── aws-alb/             # AWS Application Load Balancer resources
└── infra/
    └── testing/
        └── eu-north-1/
            └── testing-eun1-1/
                ├── eks/                # EKS cluster configuration
                ├── vpc/                # VPC configuration
                ├── argo-rollout/       # Argo Rollouts configuration
                └── eks_cluster_charts/ # EKS cluster add-ons configuration
```

## Top-Level Files

- `README.md`: Provides documentation and usage instructions for the repository.
- `root.hcl`: The root Terragrunt configuration file, used to define global settings and inputs for the infrastructure codebase.

## Common Folder

The `common/` directory contains shared Terragrunt configuration files (e.g., `eks.hcl`, `vpc.hcl`, `argo-rollout.hcl`, etc.) that define reusable settings and inputs for modules and environments. These files help standardize configuration and reduce duplication across the infrastructure codebase.

## Modules

### EKS Module
- **Purpose**: Manages EKS clusters with managed node groups
- **Features**: 
  - Custom networking with VPC CNI
  - Access management with IAM roles
  - Session Manager integration
  - Comprehensive security groups

### VPC Module
- **Purpose**: Creates VPC infrastructure with public and private subnets
- **Features**:
  - Multi-AZ deployment
  - NAT gateways for private subnet internet access
  - Route tables and security groups
  - RFC6598 subnet support for EKS

### VPC EKS Private Module
- **Purpose**: Creates a private VPC for EKS clusters
- **Features**:
  - Private subnets only
  - Enhanced security for sensitive workloads

### Argo Rollout Module
- **Purpose**: Deploys Argo Rollouts controller for progressive delivery
- **Features**:
  - Blue/green and canary deployment strategies
  - Integration with EKS

### EKS Cluster Charts Module
- **Purpose**: Deploys Helm charts for EKS cluster add-ons
- **Features**:
  - Centralized management of cluster add-ons (e.g., CoreDNS, kube-proxy)

### Karpenter Module
- **Purpose**: Deploys Karpenter autoscaler for dynamic node provisioning
- **Features**:
  - Automated scaling of EKS worker nodes
  - Cost-optimized node management

### Karpenter Configs Module
- **Purpose**: Manages Karpenter configuration resources
- **Features**:
  - Provisioner and node pool configuration
  - Custom scheduling policies

### Metric Server Module
- **Purpose**: Deploys Kubernetes metrics server
- **Features**:
  - Resource metrics for autoscaling
  - Integration with HPA/VPA

### EBS CSI Driver Module
- **Purpose**: Deploys the EBS CSI driver for dynamic volume provisioning
- **Features**:
  - Dynamic EBS volume management for Kubernetes workloads

### AWS ALB Module
- **Purpose**: Manages AWS Application Load Balancer resources
- **Features**:
  - Ingress controller integration
  - Load balancing for Kubernetes services

## Environments

### Testing Environment
- **Region**: eu-north-1 (Stockholm)
- **VPC CIDR**: 10.40.128.0/19 (private), 10.40.160.0/19 (public)
- **Additional CIDRs**: 100.64.0.0/16, 100.65.0.0/16, 100.66.0.0/16

## Usage

### Prerequisites
- AWS CLI configured
- Terragrunt installed
- Appropriate AWS permissions

### Deploying Infrastructure

1. **VPC Deployment**:
   ```bash
   cd infra/testing/eu-north-1/testing-eun1-1/vpc
   terragrunt plan
   terragrunt apply
   ```

2. **EKS Cluster Deployment**:
   ```bash
   cd infra/testing/eu-north-1/testing-eun1-1/eks
   terragrunt plan
   terragrunt apply
   ```

3. **Argo Rollout Deployment**:
   ```bash
   cd infra/testing/eu-north-1/testing-eun1-1/argo-rollout
   terragrunt plan
   terragrunt apply
   ```

4. **EKS Cluster Add-ons Deployment**:
   ```bash
   cd infra/testing/eu-north-1/testing-eun1-1/eks_cluster_charts
   terragrunt plan
   terragrunt apply
   ```

## Configuration

### Environment Variables
- `environment`: Environment name (testing, production)
- `aws_region`: AWS region for deployment

### Tags
All resources are tagged with:
- `Environment`: Environment name
- `Project`: eldurn-cluster
- `Owner`: platform-team
- `ManagedBy`: terragrunt

## Security

### EKS Security
- Private subnets for worker nodes
- Control plane logging enabled
- KMS encryption for secrets
- IAM roles for service accounts (IRSA)
- Custom security groups with specific port rules

### General Security
- Proper resource tagging
- Least privilege IAM roles
- VPC flow logs for network monitoring

## Monitoring and Logging

### EKS Logging
- API server logs
- Audit logs
- Authenticator logs
- Controller manager logs
- Scheduler logs

### Infrastructure Monitoring
- CloudWatch metrics for EKS
  
  
## Best Practices

### Infrastructure
- Use Terragrunt for consistent deployments
- Implement proper tagging for cost tracking
- Use private subnets for sensitive workloads
- Enable encryption at rest and in transit

### Security
- Follow least privilege principle
- Use IAM roles instead of access keys
- Enable VPC flow logs for network monitoring
- Implement proper security groups

## Contributing

1. Create a feature branch
2. Make changes to modules or configurations
3. Update documentation
4. Test with `terragrunt plan`
5. Submit pull request

## Support

For issues or questions:
- Check module READMEs for specific documentation
- Review Terraform plan output for configuration issues
- Verify AWS permissions and credentials
- Check CloudWatch logs for EKS issues

---

_See individual module READMEs for detailed documentation._
