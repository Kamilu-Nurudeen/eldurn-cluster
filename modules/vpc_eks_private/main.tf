locals {
  nat_gateway_count = length(var.azs)

  # Existing IPv6 prefix assignment (for reference only). 
  # private_subnet_ipv6_prefixes = [0, 1, 2, 3], public_subnet_ipv6_prefixes  = [4, 5, 6, 7]

  private_subnet_ipv6_prefixes = range(length(var.private_subnet_ipv6_prefixes) + length(var.public_subnet_ipv6_prefixes),
  length(var.private_subnet_ipv6_prefixes) + length(var.public_subnet_ipv6_prefixes) + length(var.rfc6598_subnets))
}

resource "aws_route_table" "eks_private" {
  count = length(var.rfc6598_subnets) != 0 ? local.nat_gateway_count : 0

  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index))
    },
    var.tags
  )
}

resource "aws_subnet" "eks_private" {
  count = length(var.rfc6598_subnets) != 0 ? length(var.rfc6598_subnets) : 0

  vpc_id                          = var.vpc_id
  cidr_block                      = var.rfc6598_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  assign_ipv6_address_on_creation = var.assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 && length(local.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(var.ipv6_cidr_block, 8, local.private_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      Name = format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index))
    },
    var.tags
  )
}

resource "aws_nat_gateway" "eks_private" {
  count = length(var.rfc6598_subnets) != 0 && local.nat_gateway_count != "" ? local.nat_gateway_count : 0

  connectivity_type = "private"
  subnet_id = element(
    var.private_subnets,
    count.index
  )

  tags = merge(
    {
      "Name" = format(
        "${var.name}-eks-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

resource "aws_route" "eks_private_nat_gateway" {
  count = length(var.rfc6598_subnets) != 0 && local.nat_gateway_count != "" ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.eks_private[*].id, count.index)
  destination_cidr_block = "10.0.0.0/8"
  nat_gateway_id         = element(aws_nat_gateway.eks_private[*].id, count.index)

  timeouts {
    create = "5m"
  }
}




resource "aws_route" "eks_public_nat_gateway" {
  count = length(var.rfc6598_subnets) != 0 && local.nat_gateway_count != "" ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.eks_private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(var.natgw_ids, count.index)

  timeouts {
    create = "5m"
  }
}



resource "aws_route" "eks_private_nat_gateway_egress_ipv6" {
  count = length(var.rfc6598_subnets) != 0 && var.enable_ipv6 ? length(var.rfc6598_subnets) : 0

  route_table_id              = element(aws_route_table.eks_private[*].id, count.index)
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = var.egress_only_internet_gateway_id
}

resource "aws_route_table_association" "eks_private" {
  count = length(var.rfc6598_subnets) != 0 ? length(var.rfc6598_subnets) : 0

  subnet_id      = element(aws_subnet.eks_private[*].id, count.index)
  route_table_id = element(aws_route_table.eks_private[*].id, count.index)
}
