# =============================================================================
# Provider Configuration Variables
# =============================================================================

variable "proxmox_api_url" {
  description = "Proxmox API endpoint URL (e.g., https://192.168.1.10:8006/api2/json)"
  type        = string

  validation {
    condition     = can(regex("^https?://", var.proxmox_api_url))
    error_message = "The proxmox_api_url must start with http:// or https://"
  }
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID in format: user@auth!token_name"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@]+@[^!]+![^!]+$", var.proxmox_api_token_id))
    error_message = "Token ID must be in format: user@auth!token_name"
  }
}

variable "proxmox_api_token" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (useful for self-signed certificates)"
  type        = bool
  default     = true
}

variable "proxmox_debug" {
  description = "Enable debug logging for Proxmox provider"
  type        = bool
  default     = false
}

# =============================================================================
# Proxmox Infrastructure Variables
# =============================================================================

variable "target_node" {
  description = "Target Proxmox node name"
  type        = string
  default     = "pve"
}

variable "template_name" {
  description = "Name of the cloud-init template to clone from"
  type        = string
  default     = "ubuntu-cloud-template"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for cloud-init"
  type        = string
  default     = "~/.ssh/homelab.pub"
}

# =============================================================================
# VM Default Configuration
# =============================================================================

variable "vm_defaults" {
  description = "Default values for VM configuration"
  type = object({
    memory      = number
    cores       = number
    sockets     = number
    cpu_type    = string
    disk_size   = string
    storage     = string
    ci_storage  = string
    bridge      = string
    network_tag = number
    vm_state    = string
    onboot      = bool
    bios        = string
    agent       = number
    scsihw      = string
  })
  default = {
    memory      = 2048
    cores       = 2
    sockets     = 1
    cpu_type    = "x86-64-v2-AES"
    disk_size   = "32G"
    storage     = "local-lvm"
    ci_storage  = "local"
    bridge      = "vmbr0"
    network_tag = 0
    vm_state    = "running"
    onboot      = true
    bios        = "ovmf"
    agent       = 1
    scsihw      = "virtio-scsi-single"
  }
}

# =============================================================================
# VM Instances Configuration
# =============================================================================

variable "vm_configs" {
  description = "Map of VM configurations to create"
  type = map(object({
    vm_id       = number
    name        = string
    memory      = optional(number)
    cores       = optional(number)
    sockets     = optional(number)
    cpu_type    = optional(string)
    disk_size   = optional(string)
    storage     = optional(string)
    ci_storage  = optional(string)
    vm_state    = optional(string)
    onboot      = optional(bool)
    startup     = optional(string)
    ipconfig    = string
    ciuser      = string
    cipassword  = optional(string)
    bridge      = optional(string)
    network_tag = optional(number)
    tags        = optional(list(string), [])
    description = optional(string, "Managed by OpenTofu")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.vm_configs : v.vm_id >= 100 && v.vm_id <= 999999999
    ])
    error_message = "VM IDs must be between 100 and 999999999"
  }

  validation {
    condition = alltrue([
      for k, v in var.vm_configs : can(regex("^(ip=dhcp|ip=\\d+\\.\\d+\\.\\d+\\.\\d+/\\d+)", v.ipconfig))
    ])
    error_message = "ipconfig must be either 'ip=dhcp' or 'ip=x.x.x.x/xx[,gw=x.x.x.x]'"
  }
}

# =============================================================================
# Environment and Tagging
# =============================================================================

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  default     = "homelab"

  validation {
    condition     = contains(["homelab", "dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: homelab, dev, staging, production"
  }
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "homelab-from-hell"
}
