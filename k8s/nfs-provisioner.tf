resource "helm_release" "nfs-provisioner" {
  name             = "nfs-provisioner"
  repository       = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart            = "nfs-subdir-external-provisioner"
  version          = "4.0.18"
  create_namespace = true
  namespace        = "nfs-provisioner"
  atomic           = true
  cleanup_on_fail  = true

  set {
    name  = "nfs.server"
    value = var.nfs.server
  }

  set {
    name  = "nfs.path"
    value = var.nfs.path
  }

  set {
    name  = "storageClass.name"
    value = "nfs"
  }
} 