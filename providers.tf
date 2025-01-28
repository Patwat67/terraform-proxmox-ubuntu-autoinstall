terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.70.0"
    }
    htpasswd = {
      source = "loafoe/htpasswd"
      version = "1.2.1"
    }
  }
}

provider "proxmox" {
}

provider "htpasswd" {
  alias = "password"
  # Docs: https://registry.terraform.io/providers/loafoe/htpasswd/latest/docs
}