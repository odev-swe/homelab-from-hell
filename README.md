# 🔥 Homelab From Hell

> "If it works in my lab, it might work in production. But probably not."

A production-grade Infrastructure as Code (IaC) project for managing Proxmox VE virtual machines using OpenTofu/Terraform and Ansible. This homelab automation stack handles everything from cloud-init template creation to VM provisioning and lifecycle management.

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Components](#components)
- [Workflow](#workflow)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project provides a complete automation stack for Proxmox homelab environments:

1. **Ansible** - Creates cloud-init VM templates from Ubuntu cloud images
2. **OpenTofu/Terraform** - Provisions and manages VMs from those templates

The infrastructure is designed with production best practices in mind:
- 🏗️ Modular and reusable code
- 🔐 Security-first approach with secrets management
- 📊 Comprehensive validation and error handling
- 📝 Extensive documentation
- 🏷️ Resource tagging and organization
- 🔄 Lifecycle management with state tracking

## 📁 Project Structure

```
homelab-from-hell/
├── README.md                    # This file
├── ansible/                     # Ansible automation
│   ├── ansible.cfg             # Ansible configuration
│   ├── Makefile                # Common Ansible tasks
│   ├── README.md               # Ansible documentation
│   ├── group_vars/
│   │   └── all.yml            # Global variables
│   ├── inventory/
│   │   └── hosts.yml          # Proxmox host inventory
│   └── playbooks/
│       ├── create-proxmox-template.yml
│       ├── destroy-proxmox-template.yml
│       └── sample-hello-world.yml
└── terraform/                   # OpenTofu/Terraform IaC
    ├── README.md               # Terraform documentation
    ├── Makefile                # Common Terraform tasks
    ├── provider.tf             # Provider configuration
    ├── variables.tf            # Variable definitions
    ├── locals.tf               # Computed values
    ├── main.tf                 # VM resources
    ├── outputs.tf              # Output values
    ├── cred.auto.tfvars        # Credentials (git-ignored)
    ├── terraform.tfvars.example # Example configuration
    └── .gitignore              # Ignore patterns
```

## ✨ Features

### Ansible Features
- ✅ Automated cloud-init template creation
- ✅ Ubuntu cloud image download and verification
- ✅ Customizable VM template configuration
- ✅ SSH key injection for secure access
- ✅ Template cleanup and destruction
- ✅ Idempotent playbooks

### Terraform Features
- ✅ Dynamic VM provisioning with for_each
- ✅ Configurable defaults with per-VM overrides
- ✅ Network configuration (DHCP or static IP)
- ✅ Resource tagging and metadata
- ✅ Comprehensive outputs (IPs, SSH strings, etc.)
- ✅ Input validation with custom rules
- ✅ State management and lifecycle rules
- ✅ Production-ready variable organization

## 🔧 Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| [Proxmox VE](https://www.proxmox.com/) | 7.x+ | Virtualization platform |
| [Ansible](https://www.ansible.com/) | 2.9+ | Template automation |
| [OpenTofu](https://opentofu.org/) | 1.0+ | Infrastructure management |
| SSH | Any | Remote access |

### Proxmox Setup

1. **Create API Token:**
   ```bash
   pveum user add terraform-prov@pve
   pveum aclmod / -user terraform-prov@pve -role Administrator
   pveum user token add terraform-prov@pve mytoken --privsep=0
   ```

2. **Configure SSH Access:**
   ```bash
   ssh-copy-id root@your-proxmox-host
   ```

3. **Storage Requirements:**
   - Storage for VM disks (e.g., `local-lvm`)
   - Storage for cloud-init configs (e.g., `local`)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/odev-swe/homelab-from-hell.git
cd homelab-from-hell
```

### 2. Create Cloud-Init Template

```bash
cd ansible

# Configure your Proxmox host
vim group_vars/all.yml

# Test connectivity
make ping

# Create the template
make create-template
```

### 3. Provision VMs with Terraform

```bash
cd ../terraform

# Configure credentials
cp terraform.tfvars.example cred.auto.tfvars
vim cred.auto.tfvars

# Initialize and apply
make init
make plan
make apply
```

### 4. Access Your VMs

```bash
# Get VM IP addresses
make output

# SSH into a VM
ssh ubuntu@<vm-ip>
```

## 🧩 Components

### Ansible - Template Creation

Creates reusable cloud-init templates from Ubuntu cloud images.

**Key Files:**
- `playbooks/create-proxmox-template.yml` - Main playbook
- `group_vars/all.yml` - Configuration variables
- `inventory/hosts.yml` - Proxmox host definition

**Common Tasks:**
```bash
cd ansible
make help              # Show available commands
make ping              # Test connectivity
make create-template   # Create VM template
make destroy-template  # Remove template
```

📖 [Full Ansible Documentation](ansible/README.md)

### Terraform - VM Provisioning

Manages VM lifecycle from creation to destruction.

**Key Files:**
- `main.tf` - VM resource definitions
- `variables.tf` - Input variables with validation
- `locals.tf` - Computed values and defaults
- `outputs.tf` - Useful information after apply
- `cred.auto.tfvars` - Your configuration (git-ignored)

**Common Tasks:**
```bash
cd terraform
make help      # Show available commands
make init      # Initialize Terraform
make plan      # Preview changes
make apply     # Apply changes
make output    # Show VM information
make destroy   # Destroy infrastructure
```

📖 [Full Terraform Documentation](terraform/README.md)

## 🔄 Workflow

### Complete Setup Workflow

```mermaid
graph LR
    A[Clone Repo] --> B[Configure Ansible]
    B --> C[Create Template]
    C --> D[Configure Terraform]
    D --> E[Provision VMs]
    E --> F[Access VMs]
```

### Step-by-Step

1. **Initial Setup**
   ```bash
   # Configure Ansible
   cd ansible
   vim group_vars/all.yml
   vim inventory/hosts.yml
   ```

2. **Create Template**
   ```bash
   # In ansible/
   make create-template
   # Note the template name for Terraform
   ```

3. **Configure VMs**
   ```bash
   # In terraform/
   cp terraform.tfvars.example cred.auto.tfvars
   vim cred.auto.tfvars
   # Set template_name to match Ansible template
   ```

4. **Provision Infrastructure**
   ```bash
   # In terraform/
   make init
   make plan    # Review changes
   make apply   # Confirm and apply
   ```

5. **Get VM Information**
   ```bash
   # In terraform/
   make output
   # Copy IP addresses for SSH access
   ```

## 🔐 Security Best Practices

1. **Never Commit Secrets**
   - `cred.auto.tfvars` is git-ignored
   - `*.tfvars` files are excluded
   - Use environment variables for CI/CD

2. **Use Strong Passwords**
   - Change default passwords immediately
   - Consider using SSH keys only

3. **API Token Security**
   - Use API tokens instead of passwords
   - Rotate tokens regularly
   - Use minimal required permissions

4. **Network Security**
   - Configure firewall rules
   - Use VLANs for network segmentation
   - Enable firewall on VM network interfaces

5. **State File Protection**
   - Consider remote state with encryption
   - Never commit `*.tfstate` files
   - Use state locking for team environments

## 📊 Configuration Examples

### Simple DHCP VM

```hcl
vm_configs = {
  "web-server" = {
    vm_id      = 102
    name       = "web-01"
    ipconfig   = "ip=dhcp"
    ciuser     = "ubuntu"
    cipassword = "changeme"
  }
}
```

### Production VM with Custom Resources

```hcl
vm_configs = {
  "database" = {
    vm_id       = 103
    name        = "db-prod-01"
    memory      = 16384
    cores       = 8
    disk_size   = "200G"
    storage     = "local-zfs"
    ipconfig    = "ip=192.168.100.50/24,gw=192.168.100.1"
    ciuser      = "dbadmin"
    cipassword  = "secure-password"
    tags        = ["database", "production"]
    description = "PostgreSQL Production Server"
  }
}
```

### Multiple VMs

```hcl
vm_configs = {
  "master-1" = {
    vm_id    = 110
    name     = "k8s-master-1"
    memory   = 4096
    cores    = 4
    ipconfig = "ip=192.168.100.110/24,gw=192.168.100.1"
    ciuser   = "ubuntu"
    cipassword = "changeme"
    tags     = ["kubernetes", "master"]
  }
  "worker-1" = {
    vm_id    = 111
    name     = "k8s-worker-1"
    memory   = 8192
    cores    = 4
    ipconfig = "ip=192.168.100.111/24,gw=192.168.100.1"
    ciuser   = "ubuntu"
    cipassword = "changeme"
    tags     = ["kubernetes", "worker"]
  }
}
```

## 🐛 Troubleshooting

### Common Issues

**Ansible: Cannot connect to Proxmox**
```bash
# Test SSH connectivity
ansible proxmox -m ping

# Check inventory
ansible-inventory --list
```

**Terraform: Template not found**
```bash
# Verify template exists in Proxmox
ssh root@proxmox "qm list | grep template"

# Ensure template_name matches in cred.auto.tfvars
```

**Terraform: DHCP and gateway conflict**
```hcl
# ❌ Wrong
ipconfig = "ip=dhcp,gw=192.168.100.1"

# ✅ Correct
ipconfig = "ip=dhcp"
# OR
ipconfig = "ip=192.168.100.10/24,gw=192.168.100.1"
```

**VM won't start**
```bash
# Check Proxmox logs
ssh root@proxmox "tail -f /var/log/pve/tasks/active"

# Verify resources
ssh root@proxmox "pvesh get /nodes/pve/qemu/<vmid>/status/current"
```

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly in your homelab
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow existing code structure
- Add validation for new variables
- Update documentation for changes
- Test with `make validate` before committing
- Use semantic commit messages

## 📚 Additional Resources

### Documentation
- [Ansible Documentation](https://docs.ansible.com/)
- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Proxmox VE API](https://pve.proxmox.com/pve-docs/api-viewer/)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/)

### Related Projects
- [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox)
- [Proxmox Community](https://forum.proxmox.com/)

### Learning Resources
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

## 📝 License

This project is open source and available for personal and educational use.

## 🙏 Acknowledgments

- Proxmox VE team for the excellent virtualization platform
- Telmate for the Proxmox Terraform provider
- The Ansible and OpenTofu communities

---

**⭐ If this project helped you, consider giving it a star!**

**🐛 Found a bug?** [Open an issue](https://github.com/odev-swe/homelab-from-hell/issues)

**💡 Have an idea?** [Start a discussion](https://github.com/odev-swe/homelab-from-hell/discussions)

