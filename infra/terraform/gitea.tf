resource "proxmox_lxc" "gitea" {
  hostname     = "gitea"
  vmid         = 201
  target_node  = "pve1"
  ostemplate   = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  unprivileged = true
  ostype       = "debian"
  start        = true

  cores  = 1
  memory = 512

  ssh_public_keys = var.ssh_public_key

  rootfs {
    storage = "local-lvm"
    size    = "10G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    tag    = 40
    ip     = "192.168.40.20/24"
    gw     = "192.168.40.1"
  }
}

