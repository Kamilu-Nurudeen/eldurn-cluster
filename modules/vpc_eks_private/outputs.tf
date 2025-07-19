output "rfc6598_subnet_ids" {
  description = "List of RFC6598 subnet IDs created for EKS workloads."
  value       = aws_subnet.eks_private[*].id
}
