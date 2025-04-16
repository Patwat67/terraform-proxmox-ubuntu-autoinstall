variable "proxmox_endpoint" {
    type = string
    description = "The endpoint Proxmox is contactable on {https://<ip addr>:8006/}"
    nullable = false
}

variable "proxmox_username" {
    type = string
    description = "The username used by the Proxmox Provider to authenticate with the API"
    default = "root@pam"
    nullable = false
}

variable "proxmox_password" {
    type = string
    description = "The password used by the Proxmox Provider to authenticate with the API"
    sensitive = "true"
    nullable = false
}

variable "proxmox_node" {
  type = string
  description = "The name of node to which the vm should be deployed on"
  default = "pve"
  nullable = false
}

variable "snippet_store" {
  type = string
  description = "The name of the proxmox storage to store vm snippets in"
  nullable = false
}

variable "vm_username" {
    type = string
    description = "The username used by the main VM user"
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
  description = "Hardware specifications for the VM, memory is in bytes and disk is in GiB"
  nullable = false
  validation {
    condition = var.vm_hardware.core_count > 0
    error_message = "VM must have at least 1vcpu assigned"
  }
  validation {
    condition = var.vm_hardware.memory % 1024 == 0 && var.vm_hardware.memory > 2048
    error_message = "Memory must be set in 1024 byte increments, and must be at least 2048 bytes"
  }
  validation {
    condition = var.vm_hardware.disk_size > 5
    error_message = "Disk size must be greater than 5GiB"
  }
}

variable "output_dir" {
  type = string
  description = "Directory for which generated info files should go relative to the module"
  default = "/vm-info"
  nullable = false
}

variable "LUKS_passphrase" {
  type = string
  description = "Passphrase used for LUKS disk encryption"
  nullable = true
}

variable "vm_locale" {
  type = string
  description = "Ubuntu locale"
  default = "en_US.UTF-8"
  nullable = false
}

variable "vm_timezone" {
  type = string
  description = "Ubuntu timezone"
  default = "America/New_York"
  nullable = false
}

variable "datastore_id" {
  type = string
  description = "Proxmox datastore to use to store the vms disk"
  nullable = false
}

variable "vm_gateway" {
  type = string
  description = "IP address of the gateway the VM should use to get dhcp from"
  nullable = false
}

variable "vm_image" {
  type = string
  description = "Ubuntu image to use for the VM {datastore:iso/ubuntu-image.iso}"
}

variable "vm_keyboard_layout" {
  type = string
  description = "Linux country code for keyboard layout"
  default = "us"
  nullable = false
}

variable "vm_ssh_import_id" {
  type = list
  description = "List of ssh_import_id arguments [gh:username, lp:usename, etc.]"
  nullable = true
}

variable "vm_authorized_keys" {
  type = list
  description = "List of keys to add to the users authorized_keys file"
  nullable = true
}

variable "vm_user_groups" {
  type = list
  description = "List of groups to assign the vm user [sudo, adm, docker]"
  nullable = true
}

variable "vm_tags" {
  type = list
  description = "List of tags to add to the VM within Proxmox"
  default = []
}

variable "proxmox_keyboard_layout" {
  type = string
  description = "Keyboard layout configured for the VM within the Proxmox interface"
  default = "en-us"
}

variable "vm_creation_timeout" {
  type = number
  description = "How long to wait in minutes for the VM to respond to qemu requests before terminating"
  default = 10
}

variable "vm_ballooning_memory" {
  type = bool
  description = "Enable or disable memory ballooning"
  default = true
}

variable "vm_lock_passwd" {
  type = bool
  description = "Locks the users passwd"
  default = false
}