resource "proxmox_vm_qemu" "k3s-cp-1" {
  name        = "k3s-cp-1"
  vmid        = 4041
  target_node = "pve1"

  clone      = "nixos-template"
  full_clone = true

  bios = "seabios"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory = 4096

  scsihw = "virtio-scsi-pci"

  disks {
    virtio {
      virtio0 {
        disk {
          size    = "30G"
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = "0"
    model  = "virtio"
    bridge = "vmbr0"
    tag    = 40
  }

  ipconfig0 = "ip=192.168.40.41/24,gw=192.168.40.1"

  ciuser     = "root"
  cipassword = var.k3s_nodes_ci_password
  sshkeys    = var.ssh_public_key
}
