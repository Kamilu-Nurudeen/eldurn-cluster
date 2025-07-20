module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "aws-lb-controller-${var.cluster_id}"

  attach_load_balancer_controller_policy                          = true
  attach_load_balancer_controller_targetgroup_binding_only_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:${var.service_account}"]
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  name             = "aws-load-balancer-controller"
  namespace        = "kube-system"
  repository       = var.aws_lb_controller_repository
  chart            = var.aws_lb_controller_chart
  version          = var.aws_lb_controller_chart_version
  create_namespace = true

  atomic = true

  values = [yamlencode({
    "image" : {
      "tag" : var.aws_lb_controller_version
    },
    "annotations" : {
      "prometheus.io/port" : "8080",
      "prometheus.io/scrape" : "true"
    },
    "clusterName" : var.cluster_id,
    "serviceAccountName" : "${var.service_account}",
    "serviceAccount" : {
      "create" : true,
      "annotations" : {
        "eks.amazonaws.com/role-arn" : "${module.iam_eks_role.iam_role_arn}"
      }
    }
  })]
}
