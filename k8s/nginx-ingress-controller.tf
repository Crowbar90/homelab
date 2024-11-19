resource "helm_release" "nginx-ingress-controller" {
  name             = "nginx-ingress-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.3"
  create_namespace = true
  namespace        = "nginx-ingress-controller"
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 60

  set {
    name  = "controller.service.external.enabled"
    value = true
  }
}