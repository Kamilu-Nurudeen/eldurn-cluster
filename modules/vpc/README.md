# VPC Module

## Overview

The VPC module is the foundational networking component for the Eldurn cluster infrastructure. It creates a comprehensive AWS VPC with public and private subnets, NAT gateways, and IPv6 support. This module serves as the base networking layer that other modules, particularly the `vpc_eks_private` module, build upon.

## What it does

This module creates:

### Core VPC Infrastructure
- **VPC**: A Virtual Private Cloud with configurable CIDR blocks
- **Availability Zones**: Automatically determines and uses the optimal number of AZs (3 or 4)
- **Public Subnets**: Internet-facing subnets with route tables pointing to Internet Gateway
- **Private Subnets**: Internal subnets with route tables pointing to NAT Gateways

### Networking Components
- **NAT Gateways**: One per AZ for private subnet internet access
- **Elastic IPs**: Associated with NAT Gateways
- **Route Tables**: Separate routing for public and private subnets
- **Internet Gateway**: For public subnet internet access
- **Egress-Only Internet Gateway**: For IPv6 outbound traffic

### IPv6 Support
- **Dual-stack networking**: Full IPv6 support alongside IPv4
- **DNS64**: Optional DNS64 support for IPv4-only destinations
- **IPv6 CIDR blocks**: Automatically assigned /56 IPv6 CIDR block

### Kubernetes Integration
- **EKS-ready tags**: Proper tagging for Kubernetes cluster discovery
- **ALB/ELB support**: Tags for Application and Network Load Balancers
- **Karpenter integration**: Tags for node discovery and scaling

## Key Features

### Automatic AZ Selection
```hcl
locals {
  azs_count = var.az_count_custom != null ? var.az_count_custom : length(data.aws_availability_zones.available.names) == 3 ? 3 : 4
  azs       = slice(sort(data.aws_availability_zones.available.names), 0, local.azs_count)
}
```

### Secondary CIDR Support
- Supports RFC 6598 private address space (100.64.0.0/10)
- Enables additional private subnets for EKS workloads
- Maintains separation between infrastructure and application networks

### IPv6 Prefix Management
- Automatic IPv6 prefix assignment
- Support for existing EKS cluster prefixes
- Configurable prefix ranges for public and private subnets

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  name           = "eldurn-cluster"
  private_cidr   = "10.0.0.0/16"
  public_cidr    = "10.1.0.0/16"
  rfc6598_subnets = ["100.64.0.0/16", "100.65.0.0/16"]
  
  enable_ipv6 = true
  enable_nat_gateway = true
  
  tags = {
    Environment = "production"
    Project     = "eldurn"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name for the eldurn cluster & VPC | `string` | n/a | yes |
| private_cidr | Private facing CIDR | `string` | n/a | yes |
| public_cidr | Public facing CIDR | `string` | n/a | yes |
| rfc6598_subnets | Secondary RFC 6598 Private CIDR | `list(any)` | `[]` | no |
| enable_ipv6 | Enable IPv6 support | `bool` | `true` | no |
| enable_nat_gateway | Enable NAT Gateways | `bool` | `true` | no |
| az_count_custom | Custom AZ count | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_private_subnet_ids | List of private subnet IDs |
| vpc_private_route_table_ids | List of private route table IDs |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_azs | List of availability zones used |
| natgw_ids | List of NAT Gateway IDs |
| egress_only_internet_gateway_id | The ID of the egress-only Internet Gateway |

## Relationship with vpc_eks_private

This VPC module creates the foundational networking infrastructure that the `vpc_eks_private` module extends. The relationship is hierarchical:

1. **VPC Module** creates the base VPC, public/private subnets, and NAT gateways
2. **vpc_eks_private Module** creates additional private subnets specifically for EKS workloads using RFC 6598 address space
3. The vpc_eks_private module references outputs from this VPC module:
   - `vpc_id`
   - `natgw_ids`
   - `private_subnets`
   - `ipv6_cidr_block`
   - `egress_only_internet_gateway_id`

This separation allows for:
- **Infrastructure isolation**: Base networking separate from application networking
- **Scalability**: Additional private subnets can be added without affecting existing infrastructure
- **Security**: Different security groups and routing rules for different workload types
- **Cost optimization**: Infrastructure and application resources can be managed independently

## Security Considerations

- Private subnets have no direct internet access
- NAT Gateways provide controlled outbound internet access
- IPv6 egress-only gateway for IPv6 traffic
- Proper tagging for Kubernetes service discovery
- Separate route tables for different subnet types

## Cost Optimization

- `one_nat_gateway_per_az = true` reduces NAT Gateway costs
- `reuse_nat_ips = true` reuses Elastic IPs
- Configurable AZ count to match workload requirements
- IPv6 support reduces dependency on NAT Gateways for some traffic 
