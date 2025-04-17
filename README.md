# terraform-proxmox-ubuntu-autoinstall

> **⚠️ Disclaimer**  
> **This project is a personal open-source initiative and is not affiliated with, endorsed by, or associated with any of my current or former employers. All opinions, code, and documentation are solely those of myself and the individual contributors.**  
>  
> **The project is not affiliated with Proxmox Server Solutions GmbH or any of its subsidiaries. The use of the Proxmox name and/or logo is for informational purposes only and does not imply any endorsement or affiliation with the Proxmox project.**

---

> Terraform module for deploying Ubuntu virtual machines on Proxmox VE using BPG's Proxmox provider and Ubuntu Autoinstall.  
> Easily provision cloud-init-enabled VMs with custom user data and streamlined configuration.

![Terraform](https://img.shields.io/badge/Terraform-Module-623CE4?logo=terraform&logoColor=white)
![Proxmox VE](https://img.shields.io/badge/Proxmox-VE-000000?logo=proxmox&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04-E95420?logo=ubuntu&logoColor=white)
![License](https://img.shields.io/github/license/Patwat67/terraform-proxmox-ubuntu-autoinstall)

---

## Overview

This Terraform module simplifies the provisioning of Ubuntu virtual machines on [Proxmox VE](https://www.proxmox.com/en/) by leveraging [BPG's Proxmox Terraform provider](https://github.com/bpg/terraform-provider-proxmox) and Ubuntu's cloud-init-based [Autoinstall](https://ubuntu.com/server/docs/install/autoinstall) system.

With this module, you can:

- Automate the creation of Ubuntu 20.04/22.04 virtual machines.
- Leverage Ubuntu Autoinstall for seamless, unattended OS installation.
- Supply custom cloud-init user data for flexible instance configuration.
- Integrate easily with infrastructure-as-code workflows using Terraform.

This module is ideal for developers, sysadmins, or DevOps engineers looking to efficiently bootstrap VM environments within their existing Proxmox clusters.

---

## Features

- ✅ Ubuntu Autoinstall support (20.04 / 22.04)
- ✅ BPG Proxmox provider integration
- ✅ cloud-init and user data customization
- ✅ Pre-seeding VM resources (CPU, RAM, disk, network)
- ✅ Optional SSH key injection and postinstall scripting

---

## Requirements

- Terraform `>= v1.10.5`
- BPG Proxmox Provider `>= 0.70.0`
- htpasswd Provider `>= 1.2.1`
- Proxmox VE 8.x

---

## Usage

_Documentation is WIP, this section will be updated as more features are added_

```hcl
module "ubuntu_vm" {
  source = "github.com/Patwat67/terraform-proxmox-ubuntu-autoinstall"

  # WIP
}
