output "karpenter_nodes_iam_role_name" {
  description = "Name of the IAM role for Karpenter nodes"
  value       = var.karpenter_enabled ? module.karpenter[0].karpenter_nodes_iam_role_name : null
}

output "karpenter_nodes_iam_role_arn" {
  description = "ARN of the IAM role for Karpenter nodes"
  value       = var.karpenter_enabled ? module.karpenter[0].karpenter_nodes_iam_role_arn : null
}

output "karpenter_controller_iam_role_arn" {
  description = "ARN of the IAM role used by Karpenter controller"
  value       = var.karpenter_enabled ? module.karpenter[0].karpenter_controller_iam_role_arn : null
}

output "karpenter_interruptions_queue_arn" {
  description = "ARN of the SQS queue for spot instance interruptions"
  value       = var.karpenter_enabled ? module.karpenter[0].karpenter_interaptions_queue_arn : null
}

output "karpenter_interruptions_queue_name" {
  description = "Name of the SQS queue for spot instance interruptions"
  value       = var.karpenter_enabled ? module.karpenter[0].karpenter_interaptions_queue_name : null
}
output "ec2_nodeclass_names" {
  description = "Names of the created EC2NodeClass resources"
  value       = var.karpenter_enabled ? module.karpenter_configs[0].ec2_nodeclass_names : []
}

output "nodepool_names" {
  description = "Names of the created NodePool resources"
  value       = var.karpenter_enabled ? module.karpenter_configs[0].nodepool_names : []
}

output "ec2_nodeclass_resources" {
  description = "Map of EC2NodeClass resource configurations"
  value       = var.karpenter_enabled ? module.karpenter_configs[0].ec2_nodeclass_resources : {}
}

output "nodepool_resources" {
  description = "Map of NodePool resource configurations"
  value       = var.karpenter_enabled ? module.karpenter_configs[0].nodepool_resources : {}
}
