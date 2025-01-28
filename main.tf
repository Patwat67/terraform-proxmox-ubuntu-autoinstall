resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "NAS"
  node_name = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    bootcmd: 
        - cat /proc/cmdline > /tmp/cmdline
        - sed -i'' 's/$/ autoinstall/g' /tmp/cmdline
        - mount -n --bind -o ro /tmp/cmdline /proc/cmdline
    autoinstall:
        # Documentation (Its really good) https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html
        version: 1
        locale: "en_US.UTF-8"
        # Updates installer
        refresh-installer:
            update: ${var.autoinstall_updates.installer}
            channel: lastest/edge
        drivers:
            install: ${var.autoinstall_updates.drivers}
        keyboard:
            layout: us
        # Provisions disks 
        storage:
            layout:
                name: lvm
                sizing-policy: all # Allocates all remaining storage to root dir
                # password: LUKS PASSPHRASE
        identity:
            username: ${var.vm_username}
            password: ${htpasswd_password.hash.sha512}
            hostname: ${var.vm_name}
        ssh:
            install-server: true
            authorized-keys: [${tls_private_key.key.public_key_openssh}]
            allow-pw: false
        late-commands:
            - curtin in-target -- apt-get update
            - curtin in-target -- apt-get install -y qemu-guest-agent ssh-import-id python3
            - curtin in-target -- systemctl start qemu-guest-agent
            - curtin in-target -- systemctl enable qemu-guest-agent
        timezone: America/New_York
        updates: ${var.autoinstall_updates.packages}
        shutdown: reboot # or poweroff
    EOF 
    file_name = "${var.vm_name}-user-data-cloud-config.yaml"
  }
  depends_on = [ htpasswd_password.hash, tls_private_key.key ]
}

resource "proxmox_virtual_environment_vm" "vm" {
    vm_id       = var.vm_id
    description = "Terraform"
    node_name   = "pve"
    name        = var.vm_name

    # Legacy (will not support modern features like EFI/PCIe passthrough)
    machine     = "q35"
    bios        = "ovmf"

    keyboard_layout = "en-us"

    operating_system {
        type = "l26"
    }

    # QEMU Guest agent
    agent {
        enabled = true
        timeout = "10m"
    }
    # stop_on_destroy = true

    cpu {
        cores = var.vm_hardware.core_count
        type  = "host" 
    }

    memory {
        dedicated = var.vm_hardware.memory
        floating  = var.vm_hardware.memory # Set equal enables ballooning
    }

    cdrom {
        enabled = true
        file_id = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
        interface = "ide0"
    }

    efi_disk {
        datastore_id = "store"
        file_format = "raw"
        type = "4m"
    }

    boot_order = ["scsi0", "ide0"]
    scsi_hardware = "virtio-scsi-single"
    disk {
        datastore_id = "store"
        interface    = "scsi0"
        aio = "threads"
        iothread = true
        file_format = "raw"
        size = var.vm_hardware.disk_size
        ssd = true
    }

    network_device {
        enabled = true
        model = "virtio"
    }

    initialization {
        dns {
            servers = ["10.0.0.1"]
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

resource "local_file" "ansible_vars" {
    content = <<-DOC
        # Ansible vars_file containing variable values from Terraform.
        ${var.vm_name}_ipv4: ${proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0]}
        ${var.vm_name}_user: ${var.vm_username}
        ${var.vm_name}_vm_pass: ${random_password.password.result}
        ${var.vm_name}_vm_key: ${tls_private_key.key.private_key_pem}
        DOC
    filename = "../ansible/${var.vm_name}_tf_ansible_vars_file.yaml"
}

resource "local_sensitive_file" "private_key" {
  content = tls_private_key.key.private_key_pem
  filename = "${var.private_key_path}${var.vm_name}-private_key.pem"
  file_permission = 700
}