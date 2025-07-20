# eldurn-cluster
The Terraform/Terragrunt Repository for Managing Eldurn EKS clusters' Infrastructure

## Overview

This repository contains Terraform modules and Terragrunt configurations for managing AWS infrastructure, including EKS clusters, VPC networking, and domain management for the Eldurn platform.

## Architecture

```
eldurn-cluster/
├── modules/
│   ├── eks/           # EKS cluster with managed node groups
│   ├── vpc/           # VPC with public/private subnets
│   ├── vpc_eks_private/ # Private VPC for EKS clusters
│   ├── domain/        # Main domain hosted zone and certificate
│   └── certificate-data/ # Certificate data for environments
└── infra/
    └── testing/
        └── eu-north-1/
            └── testing-eun1-1/
                ├── eks/        # EKS cluster configuration
                ├── vpc/        # VPC configuration
                ├── domain/     # Main domain configuration
                └── certificate-data/ # Certificate data configuration
```

## Modules

### EKS Module
- **Purpose**: Manages EKS clusters with managed node groups
- **Features**: 
  - Custom networking with VPC CNI
  - SSL certificates with wildcard support
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

### Domain Module
- **Purpose**: Manages main domain hosted zone and certificate
- **Features**:
  - One-time hosted zone creation for main domain
  - SSL certificate for main domain with wildcard support
  - DNS validation and certificate management

### Certificate Data Module
- **Purpose**: Retrieves certificate and zone data for environments
- **Features**:
  - Data source for main domain certificate
  - Data source for main domain hosted zone
  - Environment-agnostic certificate access

## Environments

### Testing Environment
- **Region**: eu-north-1 (Stockholm)
- **Main Domain**: hiring.docplanner.com
- **VPC CIDR**: 10.40.128.0/19 (private), 10.40.160.0/19 (public)
- **Additional CIDRs**: 100.64.0.0/16, 100.65.0.0/16, 100.66.0.0/16

## Domain Structure

```
hiring.docplanner.com (Main Domain)
├── Route53 Hosted Zone (one-time creation)
├── SSL Certificate (hiring.docplanner.com + *.hiring.docplanner.com)
└── Environment Access
    ├── test environment (retrieves certificate data)
    └── prod environment (retrieves certificate data)
```

## Usage

### Prerequisites
- AWS CLI configured
- Terragrunt installed
- Appropriate AWS permissions

### Deploying Infrastructure

1. **Domain Setup** (One-time):
   ```bash
   cd infra/testing/eu-north-1/testing-eun1-1/domain
   terragrunt plan
   terragrunt apply
   ```

2. **VPC Deployment**:
   ```bash
   cd infra/testing/eu-north-1/testing-eun1-1/vpc
   terragrunt plan
   terragrunt apply
   ```

3. **EKS Cluster Deployment**:
   ```bash
   cd infra/testing/eu-north-1/testing-eun1-1/eks
   terragrunt plan
   terragrunt apply
   ```

### Domain Setup

To create the main domain infrastructure:
1. Deploy the domain module: `cd eldurn-cluster/infra/testing/eu-north-1/testing-eun1-1/domain && terragrunt apply`
2. Deploy the certificate data module: `cd eldurn-cluster/infra/testing/eu-north-1/testing-eun1-1/certificate-data && terragrunt apply`

The domain module creates the hosted zone and certificate for `hiring.docplanner.com` (one-time), and the certificate data module retrieves this information for environments to use.

## Configuration

### Environment Variables
- `environment`: Environment name (testing, production)
- `aws_region`: AWS region for deployment
- `domain_name`: Main domain name (hiring.docplanner.com)

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

### Domain Security
- DNS-based certificate validation
- Wildcard SSL certificates
- Proper zone delegation
- Comprehensive resource tagging

## Monitoring and Logging

### EKS Logging
- API server logs
- Audit logs
- Authenticator logs
- Controller manager logs
- Scheduler logs

### Infrastructure Monitoring
- CloudWatch metrics for EKS
- Route53 health checks (configurable)
- ACM certificate monitoring

## Best Practices

### Infrastructure
- Use Terragrunt for consistent deployments
- Implement proper tagging for cost tracking
- Use private subnets for sensitive workloads
- Enable encryption at rest and in transit

### Domain Management
- Register domain only once
- Use DNS validation for certificates
- Implement proper zone delegation
- Monitor certificate expiration

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
