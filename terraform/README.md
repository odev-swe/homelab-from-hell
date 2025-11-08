# Proxmox VM Infrastructure with OpenTofu

This directory contains OpenTofu/Terraform configuration for managing Proxmox VMs using cloud-init templates.

## 🏗️ Architecture

The configuration is organized into separate files for better maintainability:

- **`provider.tf`** - Terraform and provider configuration
- **`variables.tf`** - Input variable definitions with validation
- **`locals.tf`** - Computed values and merged configurations
- **`main.tf`** - VM resource definitions
- **`outputs.tf`** - Output values for VM information
- **`cred.auto.tfvars`** - Credentials and configuration (git-ignored)
- **`terraform.tfvars.example`** - Example configuration file

## 📋 Prerequisites

1. **OpenTofu/Terraform** (>= 1.0)
2. **Proxmox VE** with API access
3. **Cloud-init template** created in Proxmox
4. **SSH key** for VM access

## 🚀 Getting Started

### 1. Configure Credentials

Copy the example configuration file:

```bash
cp terraform.tfvars.example cred.auto.tfvars
```

Edit `cred.auto.tfvars` with your Proxmox credentials and VM configurations.

### 2. Initialize Terraform

```bash
tofu init
```

### 3. Review the Plan

```bash
tofu plan
```

### 4. Apply Configuration

```bash
tofu apply
```

## 🔧 Configuration

### Basic VM Configuration

The simplest VM configuration requires:

```hcl
vm_configs = {
  "my-vm" = {
    vm_id      = 102
    name       = "my-server"
    ipconfig   = "ip=dhcp"
    ciuser     = "ubuntu"
    cipassword = "changeme"
  }
}
```

### Advanced VM Configuration

Override defaults for specific VMs:

```hcl
vm_configs = {
  "database-server" = {
    vm_id       = 103
    name        = "db-prod-01"
    memory      = 16384        # Override default
    cores       = 8            # Override default
    disk_size   = "200G"       # Override default
    storage     = "local-zfs"  # Override default
    ipconfig    = "ip=192.168.100.50/24,gw=192.168.100.1"
    ciuser      = "dbadmin"
    cipassword  = "secure-password"
    tags        = ["database", "production"]
    description = "Production PostgreSQL Database"
  }
}
```

### Network Configuration

**DHCP:**
```hcl
ipconfig = "ip=dhcp"
```

**Static IP:**
```hcl
ipconfig = "ip=192.168.100.10/24,gw=192.168.100.1"
```

**Note:** Do not combine DHCP with a gateway address.

### Default Overrides

Customize defaults for all VMs:

```hcl
vm_defaults = {
  memory      = 4096
  cores       = 4
  disk_size   = "50G"
  storage     = "local-lvm"
  vm_state    = "running"
  # ... see variables.tf for all options
}
```

## 📊 Outputs

After applying, view VM information:

```bash
# All outputs
tofu output

# Specific output
tofu output vm_ipv4_addresses
tofu output vm_ssh_hosts
tofu output configuration_summary
```

## 🔐 Security Best Practices

1. **Never commit credentials** - `cred.auto.tfvars` is git-ignored
2. **Use API tokens** instead of password authentication
3. **Rotate credentials** regularly
4. **Use strong passwords** for VM users
5. **Consider using remote state** with encryption for production

### Remote State (Production)

For team environments, configure remote state in `provider.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "homelab/proxmox/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## 🛠️ Common Operations

### List All VMs

```bash
tofu state list
```

### Show VM Details

```bash
tofu state show 'proxmox_vm_qemu.vms["vm-1"]'
```

### Destroy Specific VM

```bash
tofu destroy -target='proxmox_vm_qemu.vms["vm-1"]'
```

### Format Configuration

```bash
tofu fmt
```

### Validate Configuration

```bash
tofu validate
```

### Import Existing VM

```bash
tofu import 'proxmox_vm_qemu.vms["vm-1"]' pve/qemu/102
```

## 📦 VM Lifecycle Management

### Change VM State

Set `vm_state` to:
- `"running"` - Start the VM
- `"stopped"` - Stop the VM
- `"started"` - Ensure VM is started

### Prevent Accidental Deletion

Add to VM resource in `main.tf`:

```hcl
lifecycle {
  prevent_destroy = true
}
```

## 🏷️ Tagging Strategy

VMs are automatically tagged with:
- `environment:{env}` (e.g., `environment:homelab`)
- `project:{name}` (e.g., `project:homelab-from-hell`)
- `managed-by:opentofu`
- Custom tags from `vm_configs`

## 🐛 Troubleshooting

### Enable Debug Logging

Set in `cred.auto.tfvars`:

```hcl
proxmox_debug = true
```

### Common Issues

**"ipv4 dhcp is mutually exclusive with gateway"**
- Don't use both DHCP and gateway: `ip=dhcp,gw=x.x.x.x` ❌
- Use either: `ip=dhcp` ✅ or `ip=x.x.x.x/xx,gw=x.x.x.x` ✅

**"Template not found"**
- Ensure `template_name` matches your Proxmox template
- Check template exists: `pvesh get /cluster/resources --type vm`

**"Timeout waiting for VM"**
- Increase timeout in `main.tf` timeouts block
- Check cloud-init is working: `cloud-init status`

### View State

```bash
# Check current state
tofu show

# Refresh state
tofu refresh
```

## 📚 Additional Resources

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)

## 🤝 Contributing

When modifying this configuration:

1. Follow the existing structure
2. Add validation rules for new variables
3. Update this README for significant changes
4. Test thoroughly before applying to production
5. Use `tofu fmt` to format code

## 📝 License

Part of the homelab-from-hell project.
