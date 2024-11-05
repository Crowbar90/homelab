terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "../proxmox/output/kubeconfig"
  }
}