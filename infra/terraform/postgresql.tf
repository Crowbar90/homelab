resource "proxmox_virtual_environment_container" "postgresql" {
  node_name = "pve1"
  vm_id     = 302

  initialization {
    hostname = "postgresql"
    ip_config {
      ipv4 {
        address = "192.168.40.21/24"
        gateway = "192.168.40.1"
      }
    }
    user_account {
      keys = [var.ssh_public_key]
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }

  operating_system {
    template_file_id = "local:vztmpl/nixos-image-lxc-proxmox-25.11pre-git-x86_64-linux.tar.xz"
    type             = "nixos"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 10
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = 40
  }

  unprivileged = false
  started      = true

  lifecycle {
    ignore_changes = [
      initialization,
      operating_system
    ]
  }

  # features {
  #   nesting = true
  # }
}
