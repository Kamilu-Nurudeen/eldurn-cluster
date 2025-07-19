# VPC EKS Private Module

## Overview

The VPC EKS Private module extends the base VPC infrastructure to create additional private subnets specifically designed for EKS (Elastic Kubernetes Service) workloads. This module creates isolated networking for Kubernetes pods and services using RFC 6598 private address space, providing enhanced security and scalability for containerized applications.

## What it does

This module creates:

### EKS-Specific Private Subnets
- **RFC 6598 Subnets**: Additional private subnets using 100.64.0.0/10 address space
- **EKS-Optimized Route Tables**: Custom routing for Kubernetes workloads
- **Private NAT Gateways**: Dedicated NAT gateways for EKS subnet traffic
- **IPv6 Support**: Dual-stack networking for EKS workloads

### Advanced Routing Configuration
- **Multi-CIDR Routing**: Routes traffic for different private address ranges:
  - `10.0.0.0/8` - Standard private networks
  - `0.0.0.0/0` - Internet access via public NAT gateways
- **IPv6 Egress**: IPv6 traffic routing via egress-only internet gateway

### Kubernetes Integration
- **EKS Discovery Tags**: Proper tagging for Kubernetes service discovery
- **Load Balancer Support**: Tags for internal load balancers
- **Pod Networking**: Optimized for Kubernetes pod-to-pod communication

## Key Features

### RFC 6598 Address Space
```hcl
resource "aws_subnet" "eks_private" {
  count = length(var.rfc6598_subnets) != 0 ? length(var.rfc6598_subnets) : 0
  
  vpc_id     = var.vpc_id
  cidr_block = var.rfc6598_subnets[count.index]
  # ... other configuration
}
```

### Multi-CIDR Route Tables
The module creates comprehensive routing for different private address ranges:

```hcl
# Standard private networks
resource "aws_route" "eks_private_nat_gateway" {
  destination_cidr_block = "10.0.0.0/8"
  nat_gateway_id         = element(aws_nat_gateway.eks_private[*].id, count.index)
}
```

### Private NAT Gateways
- **Connectivity Type**: Private NAT gateways for internal traffic
- **Subnet Placement**: Placed in existing private subnets
- **Cost Optimization**: Shared with base VPC infrastructure

## Usage

```hcl
module "vpc_eks_private" {
  source = "./modules/vpc_eks_private"

  name   = "eldurn-cluster"
  vpc_id = module.vpc.vpc_id
  azs    = module.vpc.azs

  natgw_ids       = module.vpc.natgw_ids
  rfc6598_subnets = ["100.64.0.0/16", "100.65.0.0/16"]
  private_subnets = module.vpc.private_subnets
  ipv6_cidr_block = module.vpc.vpc_ipv6_cidr_block

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true
  egress_only_internet_gateway_id = module.vpc.egress_only_internet_gateway_id

  private_subnet_ipv6_prefixes = module.vpc.private_subnet_ipv6_prefixes
  public_subnet_ipv6_prefixes  = module.vpc.public_subnet_ipv6_prefixes

  tags = {
    Environment = "production"
    Project     = "eldurn"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | VPC name | `string` | `null` | no |
| vpc_id | VPC ID from base VPC module | `string` | `null` | yes |
| azs | Availability zones from base VPC | `list(string)` | `[]` | yes |
| rfc6598_subnets | RFC 6598 subnet CIDR blocks | `list(string)` | `[]` | yes |
| natgw_ids | NAT Gateway IDs from base VPC | `list(string)` | `[]` | yes |
| private_subnets | Private subnet IDs from base VPC | `list(string)` | `[]` | yes |
| ipv6_cidr_block | IPv6 CIDR from base VPC | `string` | `null` | yes |
| enable_ipv6 | Enable IPv6 support | `bool` | `false` | no |
| egress_only_internet_gateway_id | Egress-only gateway ID | `string` | `null` | no |

## Outputs

This module creates the following resources but doesn't expose specific outputs:

- **EKS Private Subnets**: Additional private subnets for EKS workloads
- **EKS Route Tables**: Custom route tables for EKS subnets
- **Private NAT Gateways**: NAT gateways for EKS subnet traffic
- **Route Table Associations**: Links subnets to route tables

## Relationship with Base VPC Module

This module is designed to work in conjunction with the base VPC module:

### Dependency Chain
1. **Base VPC Module** creates foundational infrastructure
2. **VPC EKS Private Module** extends with EKS-specific networking
3. **EKS Cluster** uses both sets of subnets for different workload types

### Resource Sharing
- **VPC ID**: Uses the same VPC created by base module
- **NAT Gateways**: References existing NAT gateways for public internet access
- **IPv6 Configuration**: Inherits IPv6 settings from base module
- **Availability Zones**: Uses the same AZs for consistency

### Network Separation
- **Infrastructure Subnets**: Base VPC private subnets for infrastructure components
- **Application Subnets**: EKS private subnets for Kubernetes workloads
- **Public Subnets**: Shared public subnets for load balancers and bastion hosts

## Architecture Benefits

### Security
- **Network Isolation**: EKS workloads isolated in dedicated subnets
- **Controlled Access**: Private NAT gateways limit outbound traffic
- **Multi-tier Security**: Different security groups for different subnet types

### Scalability
- **Additional Subnets**: Can add more RFC 6598 subnets as needed
- **Workload Separation**: Different applications can use different subnets
- **IPv6 Support**: Future-proof networking with dual-stack support

### Cost Optimization
- **Shared Infrastructure**: Reuses base VPC components
- **Private NAT Gateways**: More cost-effective than public NAT gateways
- **IPv6 Traffic**: Reduces dependency on NAT gateways for IPv6 traffic

## Use Cases

### Multi-Tenant EKS Clusters
- Different teams can use different RFC 6598 subnets
- Network policies can be applied per subnet
- Cost allocation by subnet usage

### Hybrid Cloud Connectivity
- Routes to on-premises networks (10.0.0.0/8)
- Secure internet access via NAT gateways

### Microservices Architecture
- Different microservices can use different subnets
- Network-level service isolation
- Enhanced security for sensitive workloads

## Best Practices

### Subnet Planning
- Plan RFC 6598 subnet sizes based on expected workload growth
- Use different subnets for different environments (dev, staging, prod)
- Consider IPv6 address allocation for future-proofing

### Security Groups
- Create specific security groups for EKS subnets
- Implement least-privilege access policies
- Monitor network traffic patterns

### Monitoring
- Monitor NAT gateway usage and costs
- Track subnet utilization
- Monitor IPv6 vs IPv4 traffic patterns 
