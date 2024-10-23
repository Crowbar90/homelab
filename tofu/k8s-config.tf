# k8s-config.tf
resource "proxmox_virtual_environment_download_file" "debian_12_generic_image" {
  provider     = proxmox.pve1-batcave
  node_name    = var.pve1-batcave.node_name
  content_type = "iso"
  datastore_id = "local"

  file_name          = "debian-12-generic-amd64-20241004-1890.img"
  url                = "https://cloud.debian.org/images/cloud/bookworm/20241004-1890/debian-12-generic-amd64-20241004-1890.qcow2"
  checksum           = "8ded46aa96fefbe67ad752efc59dea3a4ce7a24208c8c7bdf8396cd722762b81fe8536f2ec0050255d5197b2396e32eb380167ac1999617cfcd3ac1c15e74e3f"
  checksum_algorithm = "sha512"
}

# Make sure the "Snippets" content type is enabled on the target datastore in Proxmox before applying the configuration below.
# https://github.com/bpg/terraform-provider-proxmox/blob/main/docs/guides/cloud-init.md
resource "proxmox_virtual_environment_file" "cloud-init-ctrl-01" {
  provider     = proxmox.pve1-batcave
  node_name    = var.pve1-batcave.node_name
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = templatefile("./cloud-init/k8s-control-plane.yaml.tftpl", {
      common-config = templatefile("./cloud-init/k8s-common.yaml.tftpl", {
        hostname    = "k8s-ctrl-01"
        username    = var.vm_user
        password    = var.vm_password
        pub-key     = var.host_pub-key
        k8s-version = var.k8s-version
        kubeadm-cmd = "kubeadm init --skip-phases=addon/kube-proxy"
      })
      username           = var.vm_user
      cilium-cli-version = var.cilium-cli-version
      cilium-cli-cmd     = "HOME=/home/${var.vm_user} KUBECONFIG=/etc/kubernetes/admin.conf cilium install --set kubeProxyReplacement=true"
    })
    file_name = "cloud-init-k8s-ctrl-01.yaml"
  }
}

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
