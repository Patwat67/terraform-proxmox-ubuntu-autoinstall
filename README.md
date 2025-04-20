# terraform-proxmox-ubuntu-autoinstall

This module is for those who want to streamline their management of Ubuntu VMs within Proxmox.

## Disclaimer

The project is not affiliated with [Proxmox Server Solutions GmbH](https://www.proxmox.com/en/about/about-us/company) or any of its subsidiaries. The use of the Proxmox name and/or logo is for informational purposes only and does not imply any endorsement or affiliation with the Proxmox project.

## Overview

![Terraform](https://img.shields.io/badge/Terraform-Module-623CE4?logo=terraform&logoColor=white)
![Proxmox VE](https://img.shields.io/badge/Proxmox-VE-000000?logo=proxmox&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04-E95420?logo=ubuntu&logoColor=white)
![License](https://img.shields.io/github/license/Patwat67/terraform-proxmox-ubuntu-autoinstall)

This Terraform module simplifies the provisioning of Ubuntu virtual machines on [Proxmox VE](https://www.proxmox.com/en/) by leveraging [BPG's Proxmox Terraform provider](https://github.com/bpg/terraform-provider-proxmox) and Ubuntu's cloud-init-based [Autoinstall](https://ubuntu.com/server/docs/install/autoinstall) system.

With this module, you can:

- Automate the creation of Ubuntu virtual machines.
- Leverage Ubuntu Autoinstall for seamless, unattended OS installation.
- Supply custom cloud-init user data for flexible instance configuration.
- Integrate easily with infrastructure-as-code workflows using Terraform.


## Requirements

- Ubuntu Server `>= 20.04`
- Terraform `>= v1.10.5`
- BPG Proxmox Provider `>= 0.70.0`
- htpasswd Provider `>= 1.2.1`
- Proxmox VE 8.x


## Usage

_Documentation is WIP, this section will be updated as more features are added_

```hcl
module "ubuntu_vm" {
  source = "github.com/Patwat67/terraform-proxmox-ubuntu-autoinstall"

  # WIP
}
