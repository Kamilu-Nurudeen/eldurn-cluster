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
