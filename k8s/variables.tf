variable "nfs" {
  description = "NFS configuration for Kubernetes NFS provisioner"
  type = object({
    server = string
    path   = string
  })
}

variable "postgresql" {
  description = "PostgreSQL configuration"
  type = object({
    postgresPassword = string
  })
}