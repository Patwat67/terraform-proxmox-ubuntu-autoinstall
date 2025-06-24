output "vm_ipv4_addresses" {
    value = proxmox_virtual_environment_vm.vm.ipv4_addresses
    sensitive = false
}

output "user_data" {
    value = local.user_data
    sensitive = true
}