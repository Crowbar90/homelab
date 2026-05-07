resource "proxmox_virtual_environment_vm" "k3s-cp-3" {
  name      = "k3s-cp-3"
  vm_id     = 4043
  node_name = "pve1"
  bios      = "seabios"

  clone {
    vm_id = 9002
    full  = true
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    size         = 30
    interface    = "virtio0"
  }

  network_device {
    bridge  = "vmbr0"
    model   = "virtio"
    vlan_id = 40
  }

  lifecycle {
    ignore_changes = [
      clone,
      initialization,
      vga,
      operating_system
    ]
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.40.43/24"
        gateway = "192.168.40.1"
      }
    }
    user_account {
      username = "root"
      password = var.k3s_nodes_ci_password
      keys     = [var.ssh_public_key]
    }
  }

  agent {
    enabled = true
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/lib/sops-nix",
      "echo '${var.age_private_key}' > /var/lib/sops-nix/key.txt",
      "chmod 600 /var/lib/sops-nix/key.txt"
    ]

    connection {
      type  = "ssh"
      user  = "root"
      agent = true
      host  = "192.168.40.43"
    }
  }
}
