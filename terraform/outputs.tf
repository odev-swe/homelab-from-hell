# =============================================================================
# VM Outputs
# =============================================================================

output "vm_ids" {
  description = "Map of VM names to their Proxmox VM IDs"
  value = {
    for k, v in proxmox_vm_qemu.vms : k => v.vmid
  }
}

output "vm_names" {
  description = "Map of VM keys to their actual names"
  value = {
    for k, v in proxmox_vm_qemu.vms : k => v.name
  }
}

output "vm_ipv4_addresses" {
  description = "Map of VM names to their IPv4 addresses"
  value = {
    for k, v in proxmox_vm_qemu.vms : k => v.default_ipv4_address
  }
}

output "vm_ssh_hosts" {
  description = "Map of VM names to their SSH connection strings"
  value = {
    for k, v in proxmox_vm_qemu.vms : k => "${v.ciuser}@${v.default_ipv4_address}"
  }
}

output "vm_details" {
  description = "Detailed information about all VMs"
  value = {
    for k, v in proxmox_vm_qemu.vms : k => {
      id     = v.id
      vmid   = v.vmid
      name   = v.name
      node   = v.target_node
      state  = v.vm_state
      memory = v.memory
      cores  = v.cpu[0].cores
      ipv4   = v.default_ipv4_address
      tags   = v.tags
    }
  }
}

# =============================================================================
# Configuration Summary
# =============================================================================

output "configuration_summary" {
  description = "Summary of the Terraform configuration"
  value = {
    environment   = var.environment
    project_name  = var.project_name
    target_node   = var.target_node
    template_name = var.template_name
    total_vms     = length(proxmox_vm_qemu.vms)
    vm_count_by_state = {
      for state in distinct([for v in local.vm_configs_merged : v.vm_state]) :
      state => length([for v in local.vm_configs_merged : v if v.vm_state == state])
    }
  }
}
