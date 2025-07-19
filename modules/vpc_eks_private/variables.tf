variable "name" {
  type        = string
  description = "vpc name"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
  default     = null
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones used in the vpc"
  default     = []
}

variable "ipv6_cidr_block" {
  type        = string
  description = "IPv6 CIDR assigned to vpc"
  default     = null
}

variable "natgw_ids" {
  type        = list(string)
  description = "Nat Gateways Ids for Public Access"
  default     = []
}

variable "rfc6598_subnets" {
  type        = list(string)
  description = "Additional RFC6598 Subnets"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "Private VPC Subnets"
  default     = []
}

variable "private_subnet_suffix" {
  type        = string
  description = "Suffix to append to private subnets name"
  default     = "private-eks"
}

variable "enable_ipv6" {
  type        = bool
  description = "Should be set to the same value as in the vpc module"
  default     = false
}

variable "assign_ipv6_address_on_creation" {
  description = "Should be set to the same value as in the vpc module . Must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = false
}

variable "private_subnet_ipv6_prefixes" {
  type        = list(string)
  description = "Private IPv6 Prefixes already created in the vpc module"
  default     = []
}

variable "public_subnet_ipv6_prefixes" {
  type        = list(string)
  description = "Public IPv6 Prefixes already created in the vpc module"
  default     = []
}

variable "egress_only_internet_gateway_id" {
  type        = string
  description = "Public Egress Only Gateway IPv6"
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
