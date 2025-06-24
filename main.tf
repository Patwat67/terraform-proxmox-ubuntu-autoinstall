locals {
  user_keys = [
    for idx, user in var.user_data :
    contains(keys(user), "username") && user.username != "" ? user.username : "user-${idx}"
  ]

  password_map = {
    for idx, key in local.user_keys :
    key => random_password.password[idx].result
  }

  password_hash_map = {
    for key in local.user_keys :
    key => htpasswd_password.hash[key].sha512
  }

  user_data = [
    for idx, user in var.user_data : merge(user, {
      key                = local.user_keys[idx]
      password           = local.password_hash_map[local.user_keys[idx]]
      plaintext_password = local.password_map[local.user_keys[idx]]
    })
  ]

  networks = [
    for idx, net in var.vm_networks : merge(net, {
      mac = macaddress.mac[idx].address
    })
  ]
}

resource "macaddress" "mac" {
  for_each = { for idx, net in var.vm_networks : idx => net }

  prefix = each.value.mac_prefix
}


resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippet_store
  node_name = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/templates/cloud-config.tftpl", {
        user-data = local.user_data
        tls_public_key = tls_private_key.key.public_key_openssh
        vm_name = var.vm_hostname
        vm_locale = var.vm_locale
        vm_timezone = var.vm_timezone
        autoinstall_updates = var.autoinstall_updates
        vm_keyboard_layout = var.vm_keyboard_layout
        LUKS_passphrase = var.LUKS_passphrase

        networks = local.networks
    })
    file_name = "${var.vm_hostname}-user-data-cloud-config.yaml"
  }
  depends_on = [ htpasswd_password.hash, tls_private_key.key ]
}

resource "proxmox_virtual_environment_vm" "vm" {
    vm_id       = var.vm_id
    description = "Managed by Terraform"
    node_name   = var.proxmox_node
    name        = var.vm_hostname
    tags        = var.vm_tags

    machine     = "q35"
    bios        = "ovmf"

    keyboard_layout = var.proxmox_keyboard_layout

    operating_system {
        type = "l26"
    }

    # QEMU Guest agent
    agent {
        enabled = true
        timeout = "${var.vm_creation_timeout}m"
    }
    # stop_on_destroy = true

    cpu {
        cores = var.vm_hardware.core_count
        type  = "host" 
    }

    memory {
        dedicated = var.vm_hardware.memory
        floating  = var.vm_ballooning_memory == true ? var.vm_hardware.memory : 0
    }

    cdrom {
        enabled   = true
        file_id   = var.vm_image
        interface = "ide0"
    }

    efi_disk {
        datastore_id = var.datastore_id
        file_format  = "raw"
        type = "4m"
    }

    boot_order = ["scsi0", "ide0"]
    scsi_hardware = "virtio-scsi-single"
    disk {
        datastore_id = var.datastore_id
        interface    = "scsi0"
        aio          = "threads"
        iothread     = true
        file_format  = "raw"
        size         = var.vm_hardware.disk_size
    }

    dynamic "network_device" {
      for_each = local.networks
      content {
        enabled = true
        model   = "virtio"
        bridge = network_device.value.bridge
        mac_address = network_device.value.mac
      }
    }

    initialization {
        user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    } 
    depends_on = [ proxmox_virtual_environment_file.user_data_cloud_config ]
}

resource "random_password" "password" {
    count = length(var.user_data)
    length  = 14
    special = true
}

resource "htpasswd_password" "hash" {
    for_each = {
        for idx, pw in random_password.password :
        var.user_data[idx].username => pw
    }
    password = each.value.result
}

resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "local_sensitive_file" "info" {
    content = templatefile("${path.module}/templates/info.tftpl", {
        vm_id = var.vm_id
        vm_name = var.vm_hostname
        ip = (
          length(proxmox_virtual_environment_vm.vm.ipv4_addresses) > 1 &&
          length(proxmox_virtual_environment_vm.vm.ipv4_addresses[1]) > 0
            ? proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0]
            : (
                length(proxmox_virtual_environment_vm.vm.ipv4_addresses) > 0 &&
                length(proxmox_virtual_environment_vm.vm.ipv4_addresses[0]) > 0
                  ? proxmox_virtual_environment_vm.vm.ipv4_addresses[0][0]
                  : "0.0.0.0"
              )
            )
        user-data = local.user_data
    })
    filename = var.vm_information_files_dir == null ? "${path.root}/${var.vm_hostname}/info.txt" : "${var.vm_information_files_dir}/${var.vm_hostname}/info.txt"
    file_permission = 700
}

resource "local_sensitive_file" "private_key" {
  content = tls_private_key.key.private_key_pem
  filename = var.vm_information_files_dir == null ? "${path.root}/${var.vm_hostname}/private-key.pem" : "${var.vm_information_files_dir}/${var.vm_hostname}/private-key.pem"
  file_permission = 700
}

resource "local_file" "cloud_config" {
  content = templatefile("${path.module}/templates/cloud-config.tftpl", {
        user-data = local.user_data
        tls_public_key = tls_private_key.key.public_key_openssh
        vm_name = var.vm_hostname
        vm_locale = var.vm_locale
        vm_timezone = var.vm_timezone
        autoinstall_updates = var.autoinstall_updates
        vm_keyboard_layout = var.vm_keyboard_layout
        LUKS_passphrase = var.LUKS_passphrase

        networks = local.networks
    })
    filename = var.vm_information_files_dir == null ? "${path.root}/${var.vm_hostname}/cloud-config.txt" : "${var.vm_information_files_dir}/${var.vm_hostname}/cloud-config.txt"
}
