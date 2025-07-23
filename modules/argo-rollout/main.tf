resource "helm_release" "argo_rollout" {
  name             = var.argo_rollout_helm_release_name
  repository       = var.argo_rollout_helm_repository
  chart            = var.argo_rollout_helm_chart
  create_namespace = true
  namespace        = var.argo_rollout_namespace
  version          = var.argo_rollout_helm_version
  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      argo_rollout_dashboard_url = var.argo_rollout_dashboard_url
    })
  ]
}
