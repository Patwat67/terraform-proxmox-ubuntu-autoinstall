variable "proxmox_endpoint" {
    type = string
    description = "The endpoint Proxmox is contactable on {https://<ip addr>:8006/}"
    default = "https://10.0.0.120:8006/"
}

variable "proxmox_username" {
    type = string
    description = "The username used by the Proxmox Provider to authenticate with the API"
    default = "root@pam"
}

variable "proxmox_password" {
    type = string
    description = "The password used by the Proxmox Provider to authenticate with the API"
    sensitive = "true"
}

variable "vm_username" {
    type = string
    description = "The username used by the main VM user"
    default = "waddles"
    nullable = false
}

variable "vm_id" {
    type = number
    description = "The ID of the VM to be created"
    nullable = false
}

variable "vm_name" {
    type = string
    description = "The name of the VM to be created"
    nullable = false
}

variable "private_key_path" {
  type = string
  description = "The path to store the private key used to access the VM"
  nullable = false
  default = "../"
}

variable "additional_packages" {
  type = string
  description = "Addtional packages to install, seperated by a space"
  default = null
  nullable = true
}

variable "autoinstall_updates" {
  type = object({
    installer = bool
    drivers = bool
    packages = string
  })
  description = "Wether or not to update the installer, drivers, and/or packages."
  default = {installer = true, drivers = true, packages = "all"}
  nullable = false
  validation {
    condition = contains(["all", "security"], var.autoinstall_updates.packages)
    error_message = "Package must be 'all' or 'security'"
  }
}

variable "vm_hardware" {
  type = object({
    core_count = number
    memory = number
    disk_size = number
  })
  description = "Hardware specifications for the VM"
  nullable = false
  validation {
    condition = var.vm_hardware.core_count > 0 && var.vm_hardware.core_count <= 4
    error_message = "CPU must have at least 1 core, and not more than 4"
  }
  validation {
    condition = contains([1024, 2048, 4096], var.vm_hardware.memory)
    error_message = "Memory must be set to either 1024, 2048, or 4096"
  }
  validation {
    condition = contains([32, 64, 128], var.vm_hardware.disk_size)
    error_message = "Disk size must be either 32, 64, or 128 GB"
  }
}