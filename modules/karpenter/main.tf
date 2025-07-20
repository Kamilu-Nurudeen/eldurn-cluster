locals {
  karpenter_namespace       = "karpenter"
  karpenter_service_account = "karpenter"
}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = local.karpenter_namespace
  }
}

module "karpenter_prep" {

  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.37.1"

  cluster_name                    = var.cluster_name
  enable_irsa                     = var.enable_irsa
  enable_v1_permissions           = var.enable_v1_permissions
  irsa_oidc_provider_arn          = var.oidc_provider_arn
  irsa_namespace_service_accounts = ["${local.karpenter_namespace}:${local.karpenter_service_account}"]

  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = local.karpenter_namespace
  service_account                 = local.karpenter_service_account

  enable_pod_identity        = var.enable_pod_identity
  iam_role_name              = "KarpenterController-${var.cluster_name}"
  iam_policy_name            = "KarpenterController-${var.cluster_name}"
  iam_role_description       = "Karpenter Controller IAM role for ${var.cluster_name} cluster"
  iam_policy_description     = "Karpenter Controller IAM policy for ${var.cluster_name} cluster"
  iam_role_use_name_prefix   = false
  iam_policy_use_name_prefix = false
  iam_role_policies          = var.iam_role_policies
  iam_role_path              = var.iam_role_path

  node_iam_role_name                = "KarpenterNodes-${var.cluster_name}"
  node_iam_role_description         = "Karpenter Nodes IAM Role in the ${var.cluster_name} EKS cluster"
  node_iam_role_use_name_prefix     = false
  node_iam_role_attach_cni_policy   = var.node_iam_role_attach_cni_policy
  node_iam_role_additional_policies = var.node_iam_role_additional_policies

  create_access_entry = var.create_access_entry
  access_entry_type   = var.access_entry_type

  enable_spot_termination = var.enable_spot_termination
  tags                    = var.tags
}

locals {
  service_account_irsa_annotation = !var.enable_irsa ? {} : {
    "eks.amazonaws.com/role-arn" : module.karpenter_prep.iam_role_arn
  }

  service_account_annotations = merge(
    var.service_account_annotations,
    local.service_account_irsa_annotation
  )

  karpenter_crd_chart_v          = var.karpenter_crd_chart_v != "" ? var.karpenter_crd_chart_v : var.karpenter_chart_v
  karpenter_override_values_file = var.karpenter_override_values_file != null ? file(var.karpenter_override_values_file) : null

}

resource "helm_release" "karpenter_crd" {
  count     = var.karpenter_crd_chart_enabled ? 1 : 0
  chart     = var.karpenter_crd_chart_registry
  version   = local.karpenter_crd_chart_v
  name      = "karpenter-crd"
  namespace = local.karpenter_namespace
  timeout   = 300
  depends_on = [
    kubernetes_namespace.karpenter,
  ]
}

resource "helm_release" "karpenter" {
  count     = var.karpenter_chart_enabled ? 1 : 0
  chart     = var.karpenter_chart_registry
  version   = var.karpenter_chart_v
  name      = "karpenter"
  namespace = local.karpenter_namespace
  skip_crds = true
  timeout   = 300

  values = compact([
    yamlencode({
      "settings" : {
        "clusterName" : var.cluster_name,
        "clusterEndpoint" : var.cluster_endpoint,
        "interruptionQueue" : module.karpenter_prep.queue_name == null ? "" : module.karpenter_prep.queue_name,
      },
      "replicas" : var.replicas,
      "nodeSelector" : var.node_selector,
      "affinity" : var.affinity,
      "priorityClassName" : "system-cluster-critical",
      "serviceAccount" : {
        "create" : true,
        "name" : local.karpenter_service_account,
        "annotations" : local.service_account_annotations,
      },
      "controller" : {
        "resources" : var.controller_resources,
      },
      "logLevel" : var.log_level,
      "serviceMonitor" : {
        "enabled" : var.service_monitor_enabled,
      },
      "podLabels" : var.pod_labels,
      "podAnnotations" : var.pod_annotations,
    }),
    local.karpenter_override_values_file
  ])

  depends_on = [
    module.karpenter_prep,
    kubernetes_namespace.karpenter,
    helm_release.karpenter_crd,
  ]

}
