# main.tf
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      #version = "0.50.0"
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
    agent = true
  }

  tmp_dir = "/var/tmp"
}