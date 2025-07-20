module "irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "5.59.0"
  role_name             = "ebs-csi-driver-irsa-${var.cluster_id}"
  role_description      = "IRSA for ebs-csi-driver in ${var.cluster_id} cluster"
  attach_ebs_csi_policy = true
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa", "kube-system:ebs-csi-node-sa"]
    }
  }
  tags = var.tags
}

locals {
  helm_values_override_file = var.helm_values_override_file != null ? file(var.helm_values_override_file) : null
}

resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = var.ebs_csi_driver_repository
  chart      = var.ebs_csi_driver_chart
  version    = var.ebs_csi_driver_chart_version
  atomic     = true
  timeout    = var.helm_release_timeout

  values = compact([
    yamlencode(
      {
        "customLabels" : var.additional_labels,
        "controller" : {
          "serviceAccount" : {
            "create" : true,
            "annotations" : {
              "eks.amazonaws.com/role-arn" : module.irsa.iam_role_arn
            }
          },
          "podLabels" : var.additional_labels
        },
        "node" : {
          "serviceAccount" : {
            "create" : true,
            "annotations" : {
              "eks.amazonaws.com/role-arn" : module.irsa.iam_role_arn
            }
          }
        }
      }
    ),
    local.helm_values_override_file
  ])

  depends_on = [module.irsa]
}
