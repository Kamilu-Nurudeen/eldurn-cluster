# Add developers to EKS access. 
# Role should exist in aws account for this to work.
resource "aws_eks_access_entry" "developers" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${var.account_id}:role/eks-developers"
  type          = "STANDARD"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "developers_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.developers.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "karpenter" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${var.account_id}:role/KarpenterNodes-${module.eks.cluster_name}"
  type          = "EC2_LINUX"

  depends_on = [module.eks]
}
