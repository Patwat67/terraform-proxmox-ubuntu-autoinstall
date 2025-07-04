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
    macaddress = {
      source = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}
