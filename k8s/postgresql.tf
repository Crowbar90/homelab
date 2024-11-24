resource "helm_release" "postgresql" {
  name             = "postgresql"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "postgresql"
  version          = "16.1.1"
  create_namespace = true
  namespace        = "postgresql"
  atomic           = true
  cleanup_on_fail  = true

  set {
    name  = "architecture"
    value = "standalone"
  }

  set {
    name  = "auth.postgresPassword"
    value = var.postgresql.postgresPassword
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

locals {
  postgresql_host = "${helm_release.postgresql.name}.${helm_release.postgresql.namespace}"
}
