terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.0-beta.3"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}