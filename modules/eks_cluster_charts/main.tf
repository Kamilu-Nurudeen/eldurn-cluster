module "aws_load_balancer_controller" {
  source                          = "../aws-alb"
  cluster_id                      = var.cluster_id
  oidc_provider_arn               = var.oidc_provider_arn
  aws_lb_controller_chart_version = var.aws_lb_controller_chart_version
  aws_lb_controller_version       = var.aws_lb_controller_version
}
