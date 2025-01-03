terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.2"
    }
  }
}

provider "proxmox" {
  alias    = "pve1-batcave"
  endpoint = var.pve1-batcave.endpoint
  insecure = var.pve1-batcave.insecure

  api_token = var.pve1-batcave_auth.api_token

  ssh {
    agent    = true
    username = var.pve1-batcave.username
  }

  tmp_dir = "/var/tmp"
}
