resource "helm_release" "redis" {
  name             = "redis"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "redis"
  version          = "20.2.1"
  create_namespace = true
  namespace        = "redis"
  atomic           = true
  cleanup_on_fail  = true

  set {
    name  = "architecture"
    value = "standalone"
  }

  set {
    name  = "global.defaultStorageClass"
    value = "nfs"
  }

  set {
    name  = "volumePermissions.enabled"
    value = "true"
  }
} 