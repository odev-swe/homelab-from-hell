# =============================================================================
# Proxmox VM Resources
# =============================================================================

resource "proxmox_vm_qemu" "vms" {
  for_each = local.vm_configs_merged

  # Basic VM Configuration
  vmid        = each.value.vm_id
  name        = each.value.name
  target_node = var.target_node
  description = each.value.description

  # Clone Configuration
  clone      = var.template_name
  full_clone = false

  # BIOS and Hardware
  bios   = var.vm_defaults.bios
  agent  = var.vm_defaults.agent
  scsihw = var.vm_defaults.scsihw

  # Operating System
  os_type = "cloud-init"

  # Resources
  memory = each.value.memory

  # VM State
  vm_state = each.value.vm_state
  onboot   = each.value.onboot
  startup  = each.value.startup

  # Cloud-Init Configuration
  ipconfig0  = each.value.ipconfig
  skip_ipv6  = true
  ciuser     = each.value.ciuser
  cipassword = each.value.cipassword
  sshkeys    = file(var.ssh_public_key_path)

  # Tags
  tags = join(";", local.vm_tags[each.key])

  # CPU Configuration
  cpu {
    type    = each.value.cpu_type
    sockets = each.value.sockets
    cores   = each.value.cores
  }

  # Serial Console
  serial {
    id   = 0
    type = "socket"
  }

  # Network Configuration
  network {
    id       = 0
    model    = "virtio"
    bridge   = each.value.bridge
    firewall = true
    tag      = each.value.network_tag
  }

  # Disk Configuration
  disks {
    scsi {
      scsi0 {
        disk {
          size      = each.value.disk_size
          storage   = each.value.storage
          replicate = true
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = each.value.ci_storage
        }
      }
    }
  }

  # Lifecycle Configuration
  lifecycle {
    ignore_changes = [
      network,    # Prevent recreation on minor network changes
      cipassword, # Ignore password changes after creation
    ]
  }

  # Wait for cloud-init to complete
  timeouts {
    create = "10m"
    update = "10m"
    delete = "5m"
  }
}
