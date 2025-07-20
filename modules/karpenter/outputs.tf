output "karpenter_nodes_iam_role_arn" {
  value = module.karpenter_prep.node_iam_role_arn
}

output "karpenter_nodes_iam_role_name" {
  value = module.karpenter_prep.node_iam_role_name
}

output "karpenter_nodes_instance_profile_arn" {
  description = "AWS IAM Instance Profile applied to nodes created by Karpenter"
  value       = module.karpenter_prep.instance_profile_arn
}

output "karpenter_controller_iam_role_arn" {
  description = "IRSA - IAM Role used by Karpenter's controller"
  value       = module.karpenter_prep.iam_role_arn
}

output "karpenter_interaptions_queue_arn" {
  description = "The ARN of the SQS queue used for Spot Instances Interruptions/Terminations"
  value       = module.karpenter_prep.queue_arn
}

output "karpenter_interaptions_queue_name" {
  description = "The Name of the SQS queue used for Spot Instances Interruptions/Terminations"
  value       = module.karpenter_prep.queue_name
}
