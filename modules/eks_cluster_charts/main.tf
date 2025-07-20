module "aws_load_balancer_controller" {
  source                          = "git@github.com:Kamilu-Nurudeen/eldurn-cluster.git//modules/aws-alb"
  cluster_id                      = var.cluster_id
  oidc_provider_arn               = var.oidc_provider_arn
  aws_lb_controller_chart_version = var.aws_lb_controller_chart_version
  aws_lb_controller_version       = var.aws_lb_controller_version
}

module "ebs_csi_driver" {
  count                        = var.ebs_csi_driver_enabled ? 1 : 0
  source                       = "git@github.com:Kamilu-Nurudeen/eldurn-cluster.git//modules/ebs-csi-driver"
  cluster_id                   = var.cluster_id
  oidc_provider_arn            = var.oidc_provider_arn
  ebs_csi_driver_chart_version = var.ebs_csi_driver_chart_version
  ebs_csi_driver_repository    = var.ebs_csi_driver_repository
}

module "metric_server" {
  source                           = "git@github.com:Kamilu-Nurudeen/eldurn-cluster.git//modules/metric-server"
  metric_server_helm_chart_version = var.metric_server_helm_chart_version
  metric_server_helm_repository    = var.metric_server_helm_repository
  metric_server_resources          = var.metric_server_resources
}

module "karpenter" {
  source                      = "git@github.com:Kamilu-Nurudeen/eldurn-cluster.git//modules/karpenter"
  count                       = var.karpenter_enabled ? 1 : 0
  karpenter_chart_enabled     = var.karpenter_chart_enabled
  karpenter_crd_chart_enabled = var.karpenter_crd_chart_enabled
  karpenter_chart_v           = var.karpenter_chart_v
  karpenter_crd_chart_v       = var.karpenter_crd_chart_v
  cluster_name                = var.cluster_id
  cluster_endpoint            = var.cluster_endpoint
  oidc_provider_arn           = var.oidc_provider_arn
  replicas                    = var.karpenter_replicas
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
}

module "karpenter_configs" {
  source = "git@github.com:Kamilu-Nurudeen/eldurn-cluster.git//modules/karpenter-configs"
  count  = var.karpenter_enabled ? 1 : 0

  cluster_name                  = var.cluster_id
  karpenter_nodes_iam_role_name = var.karpenter_enabled ? module.karpenter[0].karpenter_nodes_iam_role_name : "KarpenterNodes-${var.cluster_id}"
  availability_zones            = var.availability_zones
  associate_public_ip_address   = var.associate_public_ip_address

  ec2_nodeclasses     = var.ec2_nodeclasses
  nodepools           = var.nodepools
  default_annotations = var.karpenter_default_annotations
  default_labels      = var.karpenter_default_labels
  default_tags        = var.karpenter_default_tags


  depends_on = [module.karpenter]
}
