output "vm_ipv4_address" {
    value = proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0]
    sensitive = false
}

output "private_key" {
    value = tls_private_key.key.private_key_pem
    sensitive = true
}

output "password" {
    value = random_password.password.result
    sensitive = true
}

output "vm_username" {
    value = var.vm_username
    sensitive = false
}