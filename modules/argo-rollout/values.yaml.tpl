installCRDs: true
keepCRDs: true
dashboard:
  enabled: true
  ingress:
    enabled: false
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
      alb.ingress.kubernetes.io/backend-protocol: HTTP
      alb.ingress.kubernetes.io/backend-protocol-version: HTTP1
    labels:
      kubernetes.io/ingress.class: alb
    ingressClassName: ""
    hosts:
      - ${argo_rollout_dashboard_url}
    paths:
      - /
    pathType: Prefix
    extraPaths: []
