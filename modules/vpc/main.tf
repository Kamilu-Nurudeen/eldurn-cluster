data "aws_availability_zones" "available" {}

resource "aws_eip" "nat" {
  count = local.azs_count

  domain = "vpc"
}

locals {
  ## a value of 0 will ONLY create the VPC with no subnets/azs
  azs_count = var.az_count_custom != null ? var.az_count_custom : length(data.aws_availability_zones.available.names) == 3 ? 3 : 4
  azs       = slice(sort(data.aws_availability_zones.available.names), 0, local.azs_count)

  private_subnets = [for k, v in local.azs : cidrsubnet(var.private_cidr, 2, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.public_cidr, 2, k)]

  secondary_cidr_blocks = var.rfc6598_subnets != "" ? concat([var.public_cidr], var.rfc6598_subnets) : [var.public_cidr]

  # Supports prefixes that were assigned in existing eks clusters.
  # Comments below are for legacy reference
  # private_subnet_ipv6_prefixes = [0, 1, 2, 3]
  # public_subnet_ipv6_prefixes  = [4, 5, 6, 7]
  private_subnet_ipv6_prefixes = range(local.azs_count)
  public_subnet_ipv6_prefixes  = range(local.azs_count, 2 * local.azs_count)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.0"

  name                  = var.name
  cidr                  = var.private_cidr
  secondary_cidr_blocks = toset(local.secondary_cidr_blocks)

  azs = local.azs

  private_subnets              = local.private_subnets
  public_subnets               = local.public_subnets
  private_subnet_ipv6_prefixes = local.private_subnet_ipv6_prefixes
  public_subnet_ipv6_prefixes  = local.public_subnet_ipv6_prefixes

  enable_ipv6                                                   = var.enable_ipv6
  private_subnet_enable_dns64                                   = var.private_subnet_enable_dns64
  public_subnet_enable_dns64                                    = var.public_subnet_enable_dns64
  manage_default_network_acl                                    = var.manage_default_network_acl
  manage_default_route_table                                    = var.manage_default_route_table
  manage_default_security_group                                 = var.manage_default_security_group
  private_subnet_enable_resource_name_dns_aaaa_record_on_launch = var.private_subnet_enable_resource_name_dns_aaaa_record_on_launch
  public_subnet_enable_resource_name_dns_aaaa_record_on_launch  = var.public_subnet_enable_resource_name_dns_aaaa_record_on_launch
  private_subnet_assign_ipv6_address_on_creation                = var.private_subnet_assign_ipv6_address_on_creation
  public_subnet_assign_ipv6_address_on_creation                 = var.public_subnet_assign_ipv6_address_on_creation
  map_public_ip_on_launch                                       = var.map_public_ip_on_launch
  enable_nat_gateway                                            = var.enable_nat_gateway
  reuse_nat_ips                                                 = var.reuse_nat_ips
  one_nat_gateway_per_az                                        = var.one_nat_gateway_per_az
  external_nat_ip_ids                                           = aws_eip.nat.*.id
  enable_dns_hostnames                                          = var.enable_dns_hostnames # This has to be true

  tags = var.tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/alb-ingress"    = ""
    "kubernetes.io/role/elb"            = ""
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
    "karpenter.sh/discovery"            = var.name
  }
}

module "vpc_eks_private" {
  source = "git::https://github.com/Kamilu-Nurudeen/eldurn-cluster.git//modules/vpc_eks_private"

  name   = var.name
  vpc_id = module.vpc.vpc_id
  azs    = local.azs

  natgw_ids       = module.vpc.natgw_ids
  rfc6598_subnets = var.rfc6598_subnets
  private_subnets = module.vpc.private_subnets
  ipv6_cidr_block = module.vpc.vpc_ipv6_cidr_block

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true
  egress_only_internet_gateway_id = module.vpc.egress_only_internet_gateway_id

  private_subnet_ipv6_prefixes = local.private_subnet_ipv6_prefixes
  public_subnet_ipv6_prefixes  = local.public_subnet_ipv6_prefixes

  depends_on = [
    module.vpc
  ]
}
