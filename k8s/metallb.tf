resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  version          = "0.14.8"
  create_namespace = false
  namespace        = "kube-system"
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300
}