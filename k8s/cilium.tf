resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.16.3"
  create_namespace = false
  namespace        = "kube-system"
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 60

  set {
    name  = "cluster.name"
    value = "kubernetes"
  }

  set {
    name  = "k8sServiceHost"
    value = "192.168.2.150"
  }

  set {
    name  = "k8sServicePort"
    value = 6443
  }

  set {
    name  = "kubeProxyReplacement"
    value = true
  }

  set {
    name  = "operator.replicas"
    value = 1
  }

  set {
    name  = "routingMode"
    value = "tunnel"
  }

  set {
    name  = "tunnelProtocol"
    value = "vxlan"
  }

  set {
    name  = "ingressController.enabled"
    value = false
  }

  set {
    name  = "ingressController.hostNetwork.enabled"
    value = false
  }
}
