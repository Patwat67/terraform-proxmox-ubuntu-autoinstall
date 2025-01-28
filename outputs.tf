output "vm_ipv4_address" {
    value = proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0]
}

output "vm_password" {
  value = random_password.password.result
}