resource "proxmox_virtual_environment_vm" "k8s-ctrl-01" {
  provider  = proxmox.pve1-batcave
  node_name = var.pve1-batcave.node_name

  name        = "k8s-ctrl-01"
  description = "Kubernetes Control Plane 01"
  tags        = ["k8s", "control-plane"]
  on_boot     = true
  vm_id       = 8001

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = "BC:24:11:2E:C0:01"
  }

  efi_disk {
    datastore_id = "local"
    file_format  = "raw" // To support qcow2 format
    type         = "4m"
  }

  disk {
    datastore_id = "local"
    file_id      = proxmox_virtual_environment_download_file.debian_12_generic_image.id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    size         = 32
  }

  boot_order = ["scsi0"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  initialization {
    dns {
      domain  = var.vm_dns.domain
      servers = var.vm_dns.servers
    }
    ip_config {
      ipv4 {
        address = "192.168.2.150/24"
        gateway = "192.168.2.1"
      }
    }

    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.cloud-init-ctrl-01.id
  }
}