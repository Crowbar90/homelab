resource "proxmox_virtual_environment_file" "cloud-init-work-01" {
  provider     = proxmox.pve1-batcave
  node_name    = var.pve1-batcave.node_name
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = templatefile("./cloud-init/k8s-worker.yaml.tftpl", {
      common-config = templatefile("./cloud-init/k8s-common.yaml.tftpl", {
        hostname    = "k8s-work-01"
        username    = var.vm_user
        password    = var.vm_password
        pub-key     = var.host_pub-key
        k8s-version = var.k8s-version
        kubeadm-cmd = module.kubeadm-join.stdout
      })
    })
    file_name = "cloud-init-k8s-work-01.yaml"
  }
}
