output "name" {
  value = module.vpc.name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "vpc_private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_azs" {
  value = module.vpc.azs
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}

output "main_route_table_id" {
  value = module.vpc.vpc_main_route_table_id
}


output "secondary_cidr_blocks" {
  value = module.vpc.vpc_secondary_cidr_blocks
}
