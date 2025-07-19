variable "environment" {
  type        = string
  description = "VPC environment"
  default     = "dev"
}

variable "name" {
  type        = string
  description = "Name for the eldurn cluster & VPC"
}

variable "private_cidr" {
  type        = string
  description = "Private facing CIDR"
}

variable "public_cidr" {
  type        = string
  description = "Public facing CIDR"
}

variable "rfc6598_subnets" {
  type        = list(any)
  default     = []
  description = "Secondary RFC 6598 Private CIDR"
}

variable "enable_vpc_endpoints" {
  type        = bool
  description = "Enable vpc endpoints module"
  default     = "false"
}

variable "tags" {
  type        = map(string)
  description = "tags"
}

variable "enable_ipv6" {
  type        = bool
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block"
  default     = true
}

variable "private_subnet_enable_dns64" {
  type        = bool
  description = "Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations."
  default     = false
}

variable "public_subnet_enable_dns64" {
  type        = bool
  description = "Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations."
  default     = false
}

variable "manage_default_network_acl" {
  type        = bool
  description = "Should be true to adopt and manage Default Network ACL"
  default     = false
}

variable "manage_default_route_table" {
  type        = bool
  description = "Should be true to manage default route table"
  default     = false
}

variable "manage_default_security_group" {
  type        = bool
  description = "Should be true to adopt and manage default security group"
  default     = false
}

variable "private_subnet_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records."
  default     = false
}

variable "public_subnet_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records"
  default     = false
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address."
  default     = true
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address."
  default     = true
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "reuse_nat_ips" {
  type        = bool
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  default     = true
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "az_count_custom" {
  type        = number
  description = "specify custom az count"
  default     = null
}
