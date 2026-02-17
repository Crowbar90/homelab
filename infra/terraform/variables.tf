variable "ssh_public_key" {
  description = "Ansible SSH public key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGq1LqdI1v0Mda8ky+0GE03tPAbSxWE3BEq9DfyCUi0 toolbox@homelab.internal.middleearth.cc"
}

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

