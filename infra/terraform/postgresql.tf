resource "proxmox_lxc" "postgresql" {
  hostname     = "postgresql"
  vmid         = 302
  target_node  = "pve1"
  ostemplate   = "local:vztmpl/nixos-image-lxc-proxmox-25.11pre-git-x86_64-linux.tar.xz"
  unprivileged = false
  ostype       = "nixos"
  start        = true

  cores  = 1
  memory = 1024

  ssh_public_keys = var.ssh_public_key

  rootfs {
    storage = "local-lvm"
    size    = "10G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    tag    = 40
    ip     = "192.168.40.21/24"
    gw     = "192.168.40.1"
  }

  #features {
  #  nesting = true
  #}
}

