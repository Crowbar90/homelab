resource "helm_release" "nfs-provisioner" {
  name             = "nfs-provisioner"
  repository       = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart            = "nfs-subdir-external-provisioner"
  version          = "4.0.18"
  create_namespace = true
  namespace        = "nfs-provisioner"
  atomic           = true

  set {
    name  = "nfs.server"
    value = "tower.batcave"
  }

  set {
    name  = "nfs.path"
    value = "/mnt/user/kubernetes"
  }

  set {
    name  = "storageClass.name"
    value = "nfs"
  }
} 