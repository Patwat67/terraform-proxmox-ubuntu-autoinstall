output "vm_ipv4_address" {
    value = proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0]
    sensitive = false
}

output "user_data" {
    value = local.user_data
    sensitive = true
}