resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippet_store
  node_name = var.proxmox_node

  source_raw {
    data = <<-DOC
    #cloud-config
    bootcmd: 
        - cat /proc/cmdline > /tmp/cmdline
        - sed -i'' 's/$/ autoinstall/g' /tmp/cmdline
        - mount -n --bind -o ro /tmp/cmdline /proc/cmdline
    autoinstall:
        # Documentation (Its really good) https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html
        version: 1
        locale: ${var.vm_locale}
        # Updates installer
        refresh-installer:
            update: ${var.autoinstall_updates.installer}
            channel: lastest/edge
        drivers:
            install: ${var.autoinstall_updates.drivers}
        keyboard:
            layout: ${var.vm_keyboard_layout}
        # Provisions disks 
        storage:
            layout:
                name: lvm
                sizing-policy: all # Allocates all remaining storage to root dir
                ${format("password: %s", coalesce(var.LUKS_passphrase, "~"))}
        user-data:
            users:
                - name: ${var.vm_username}
                gecos: "Terraform"
                primary_group: ${var.vm_username}
                groups: ${length(var.vm_user_groups) > 0 ? join(",", var.vm_user_groups) : []}
                shell: /bin/bash
                lock_passwd: True
                passwd: ${htpasswd_password.hash.sha512}
                sudo: ALL=(ALL) NOPASSWD:ALL
                ssh_import_id: ${length(var.vm_ssh_import_id) > 0 ? var.vm_ssh_import_id : []}
                ssh_authorized_keys: ${length(var.vm_authorized_keys) > 0 ? concat(var.vm_authorized_keys, [tls_private_key.key.public_key_openssh]) : tls_private_key.key.public_key_openssh}
        identity:
            username: ${var.vm_username}
            password: ${htpasswd_password.hash.sha512}
            hostname: ${var.vm_name}

        late-commands:
            - curtin in-target -- apt-get update
            - curtin in-target -- apt-get install -y qemu-guest-agent ssh-import-id python3
            - curtin in-target -- systemctl start qemu-guest-agent
            - curtin in-target -- systemctl enable qemu-guest-agent
        timezone: ${var.vm_timezone}
        updates: ${var.autoinstall_updates.packages}
        shutdown: reboot # must be reboot so that qemu guest agent works
    DOC
    file_name = "${var.vm_name}-user-data-cloud-config.yaml"
  }
  depends_on = [ htpasswd_password.hash, tls_private_key.key ]
}

resource "proxmox_virtual_environment_vm" "vm" {
    vm_id       = var.vm_id
    description = "Terraform"
    node_name   = var.proxmox_node
    name        = var.vm_name
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
        timeout = "${var.vm_creation_timeout}}m"
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
        enabled = true
        file_id = var.vm_image
        interface = "ide0"
    }

    efi_disk {
        datastore_id = var.datastore_id
        file_format = "raw"
        type = "4m"
    }

    boot_order = ["scsi0", "ide0"]
    scsi_hardware = "virtio-scsi-single"
    disk {
        datastore_id = var.datastore_id
        interface    = "scsi0"
        aio = "threads"
        iothread = true
        file_format = "raw"
        size = var.vm_hardware.disk_size
    }

    network_device {
        enabled = true
        model = "virtio"
    }

    initialization {
        dns {
            servers = [var.vm_gateway]
        }
        ip_config {
            ipv4 {
                address = "dhcp"
            }
        }
        user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    } 
    depends_on = [ proxmox_virtual_environment_file.user_data_cloud_config ]
}

resource "random_password" "password" {
    length           = 14
    special          = true
}

resource "htpasswd_password" "hash" {
  password = random_password.password.result
}

resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "local_sensitive_file" "info" {
    content = <<-DOC
        id: ${var.vm_id}
        name: ${var.vm_name}

        ipv4: ${proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0]}
        user: ${var.vm_username}
        pass: ${random_password.password.result}
    DOC
    filename = "${path.module}/${var.output_dir}/${var.vm_name}/info.txt"
    file_permission = 700
}

resource "local_sensitive_file" "private_key" {
  content = tls_private_key.key.private_key_pem
  filename = "${path.module}/${var.output_dir}/${var.vm_name}/private-key.pem"
  file_permission = 700
}

resource "local_sensitive_file" "connect" {
    content = <<-DOC
    #!/bin/bash
    ssh ${var.vm_name}@${proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0]} -i ${path.module}/${var.output_dir}/${var.vm_name}/private-key.pem
    DOC
    filename = "${path.module}/${var.output_dir}/${var.vm_name}/connect.sh"
    file_permission = 700
}