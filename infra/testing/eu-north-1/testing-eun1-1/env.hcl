locals {
  environment            = "testing"
  is_production          = false
  hosted_zone            = "testing.eldurn.com"
  name                   = "testing-eun1-1"
  vpc_private_cidr       = "10.40.128.0/19" #private cidrs of cluster vpc
  vpc_public_cidr        = "10.40.160.0/19" #public cidrs of cluster vpc
  increment              = "1"
  coredns_replica_count  = 2
  enable_vpc_endpoints   = false
  // should be equal to the number of azs being used 
  additional_vpc_cidrs       = ["100.64.0.0/16", "100.65.0.0/16", "100.66.0.0/16"]
}
