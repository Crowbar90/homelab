resource "helm_release" "adminer" {
  name             = "adminer"
  repository       = "https://startechnica.github.io/apps"
  chart            = "adminer"
  version          = "0.1.8 "
  create_namespace = true
  namespace        = "adminer"
  atomic           = true
  cleanup_on_fail  = true

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "ingress.path"
    value = "/"
  }

  set {
    name  = "ingress.pathType"
    value = "Prefix"
  }

  set {
    name  = "ingress.hostname"
    value = "adminer.k8s.batcave"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "global.storageClass"
    value = "nfs"
  }
} 