variable "nfs" {
  description = "NFS configuration for Kubernetes NFS provisioner"
  type = object({
    server = string
    path   = string
  })
}
