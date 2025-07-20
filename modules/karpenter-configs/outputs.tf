output "ec2_nodeclass_names" {
  description = "Names of the created EC2NodeClass resources"
  value       = keys(var.ec2_nodeclasses)
}

output "nodepool_names" {
  description = "Names of the created NodePool resources"
  value       = keys(var.nodepools)
}

output "ec2_nodeclass_resources" {
  description = "Map of EC2NodeClass resource configurations"
  value       = var.ec2_nodeclasses
}

output "nodepool_resources" {
  description = "Map of NodePool resource configurations"
  value       = var.nodepools
}
