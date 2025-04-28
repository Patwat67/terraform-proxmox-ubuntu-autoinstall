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

variable "vm_id" {
    type = number
    description = "The ID of the VM to be created"
    nullable = false
}

variable "vm_hostname" {
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
    packages = string
  })
  description = "Wether or not to update the installer and/or packages."
  default = {installer = true, packages = "all"}
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

variable "LUKS_passphrase" {
  type = string
  description = "Passphrase used for LUKS disk encryption"
  nullable = true
  default = null
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

variable "vm_networks" {
  type = list(object({
    interface_name = string
    ipv4 = string
    gateway4 = optional(string, null)
    bridge = string
    dns_servers = optional(list(string), null)
    dns_domains = optional(list(string), null)
    mac_prefix = optional(list(number), [ 2 ])
  }))
  description = "VMs network settings, defaults to DHCP if not set"
  default = [ {
    interface_name = "eth0"
    ipv4 = "dhcp"
    gateway4 = null
    bridge = "vmbr0"
    dns_servers = null
    dns_domains = null
    mac_prefix = [ 2 ]
  } ]
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
  default = 15
}

variable "vm_ballooning_memory" {
  type = bool
  description = "Enable or disable memory ballooning"
  default = true
}

variable "vm_information_files_dir" {
  type = string
  description = "Directory to store vm_information_files, leave null to store in root"
  nullable = true
  default = null
}

variable "user_data" {
  type = list(
      object({
        username = optional(string, "ubuntu")
        user_groups = optional(list(string), ["adm","cdrom","lpadmin","sudo","sambashare","dip","plugdev"])
        system = optional(bool, false)
        lock_passwd = optional(bool, false)
        ssh_import_ids = optional(list(string), null)
        authorized_keys = optional(list(string), [])
      })
    )
  description = "Configures the user-data section of the VMs cloud-config, see documentation"
  nullable = false
}
