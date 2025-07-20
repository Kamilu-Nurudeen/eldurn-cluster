resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = var.metric_server_helm_repository
  chart      = var.metric_server_helm_chart
  version    = var.metric_server_helm_chart_version
  timeout    = var.helm_release_timeout

  atomic = true
  values = [yamlencode({
    "metrics" : {
      "enabled" : "true"
    },
    "resources" : var.metric_server_resources
  })]
}
