terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "../proxmox/output/kubeconfig"
  }
}

provider "postgresql" {
  host     = "localhost"
  port     = 5432
  username = "postgres"
  password = var.postgresql.postgresPassword
  sslmode  = "disable"
}
