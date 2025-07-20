variable "metric_server_helm_repository" {
  type    = string
  default = "https://kubernetes-sigs.github.io/metrics-server"
}

variable "metric_server_helm_chart" {
  type    = string
  default = "metrics-server"
}

variable "metric_server_helm_chart_version" {
  type    = string
  default = "3.12.2"
}

variable "metric_server_resources" {
  type = map(object({
    cpu    = string
    memory = string
  }))
  description = "Metrics-server deployment resources"
  default     = {}
}

variable "helm_release_timeout" {
  type        = number
  description = "helm release timout in seconds. default 300s"
  default     = 1000
}
