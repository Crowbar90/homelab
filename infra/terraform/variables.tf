# Identity
variable "ssh_public_key" {
  description = "Ansible SSH public key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGq1LqdI1v0Mda8ky+0GE03tPAbSxWE3BEq9DfyCUi0 toolbox@homelab.internal.middleearth.cc"
}

# Proxmox Virtual Environment
variable "proxmox_api_url" {
  description = "The Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "The Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "The Proxmox API token secret"
  type        = string
  sensitive   = true
}

# K3s
variable "k3s_nodes_ci_password" {
  description = "The K3S nodes cloud-init password"
  type        = string
  sensitive   = true
}

# Cloudflare
variable "cloudflare_zone" {
  description = "Cloudflare domain"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for your domain"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Email address for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}
variable "age_private_key" {
  description = "Age private key for sops-nix"
  type        = string
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for provisioning"
  type        = string
  default     = "~/.ssh/id_ed25519"
}
