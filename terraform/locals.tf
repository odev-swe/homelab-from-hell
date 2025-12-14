# =============================================================================
# Local Values for Computed Configuration
# =============================================================================

locals {
  # Merge VM configs with defaults
  vm_configs_merged = {
    for k, v in var.vm_configs : k => {
      vm_id       = v.vm_id
      name        = v.name
      memory      = coalesce(v.memory, var.vm_defaults.memory)
      cores       = coalesce(v.cores, var.vm_defaults.cores)
      sockets     = coalesce(v.sockets, var.vm_defaults.sockets)
      cpu_type    = coalesce(v.cpu_type, var.vm_defaults.cpu_type)
      disk_size   = coalesce(v.disk_size, var.vm_defaults.disk_size)
      storage     = coalesce(v.storage, var.vm_defaults.storage)
      ci_storage  = coalesce(v.ci_storage, var.vm_defaults.ci_storage)
      vm_state    = coalesce(v.vm_state, var.vm_defaults.vm_state)
      onboot      = coalesce(v.onboot, var.vm_defaults.onboot)
      startup     = v.startup
      ipconfig    = v.ipconfig
      ciuser      = v.ciuser
      cipassword  = v.cipassword
      nameserver  = coalesce(v.nameserver, var.vm_defaults.nameserver)
      bridge      = coalesce(v.bridge, var.vm_defaults.bridge)
      network_tag = coalesce(v.network_tag, var.vm_defaults.network_tag)
      tags        = v.tags
      description = v.description
    }
  }

  # Common tags for all resources (Proxmox tag format: alphanumeric, dash, dot, underscore only)
  common_tags = [
    "env-${var.environment}",
    "project-${replace(var.project_name, "/[^a-zA-Z0-9-_.]/", "-")}",
    "managed-by-opentofu"
  ]

  # Combine common tags with VM-specific tags
  vm_tags = {
    for k, v in local.vm_configs_merged : k => concat(
      local.common_tags,
      [for tag in v.tags : tag]
    )
  }
}
