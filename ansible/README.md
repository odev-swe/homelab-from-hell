# Ansible Automation for Homelab

This directory contains Ansible playbooks for automating various homelab tasks including Proxmox template creation, Tailscale VPN installation, and Kubernetes cluster setup.

## Prerequisites

- Ansible installed on your local machine
- SSH access to your Proxmox host as root
- SSH key configured for passwordless authentication

## Setup

1. **Configure your Proxmox host:**
   Edit `group_vars/all.yml` and set:
   - `proxmox_host`: Your Proxmox server IP address
   - Other settings as needed

2. **Update inventory:**
   Edit `inventory/hosts.yml` if needed to match your SSH configuration

3. **Add your SSH key (optional but recommended):**
   Edit `group_vars/all.yml` and add your SSH public key to `cloudinit_ssh_key`

## Usage

### Run the playbook:

```bash
cd ansible
ansible-playbook playbooks/create-proxmox-template.yml
```

### With custom variables:

```bash
ansible-playbook playbooks/create-proxmox-template.yml \
  -e "template_id=9001" \
  -e "template_name=ubuntu-22-04-template" \
  -e "ubuntu_version=22.04"
```

### Test connectivity first:

```bash
ansible proxmox -m ping
```

## Configuration Options

All configuration options are in `group_vars/all.yml`:

- **template_id**: VM ID for the template (default: 9000)
- **template_name**: Name of the template (default: ubuntu-cloud)
- **template_storage**: Proxmox storage location (default: local)
- **ubuntu_version**: Ubuntu version to use (default: 22.04)
- **vm_memory**: Memory in MB (default: 2048)
- **vm_cores**: CPU cores (default: 2)
- **vm_disk_size**: Disk size (default: 32G)

## Ubuntu Versions Available

- **20.04 (Focal)**: `https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img`
- **22.04 (Jammy)**: `https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img`
- **24.04 (Noble)**: `https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img`

Update `ubuntu_image_url` and `ubuntu_image_name` in `group_vars/all.yml` to use a different version.

## What the Playbook Does

1. Checks if a template with the specified ID already exists
2. Downloads the Ubuntu cloud image from Ubuntu's official repository
3. Creates a new VM with the specified configuration
4. Imports the cloud image as the VM's disk
5. Adds EFI disk for UEFI boot support
6. Configures cloud-init settings
7. Resizes the disk to the specified size
8. Converts the VM to a template
9. Cleans up the downloaded image file

## Troubleshooting

- **SSH Connection Issues**: Ensure your SSH key is added to the Proxmox host's `authorized_keys`
- **Permission Denied**: Make sure you're connecting as root or a user with sudo privileges
- **Template Already Exists**: The playbook will destroy and recreate the template if it exists
- **Storage Issues**: Verify that the storage specified in `template_storage` exists on your Proxmox node

## After Template Creation

Your template will be ready to use with Terraform/OpenTofu. The template name `ubuntu-cloud` matches what's referenced in your `main.tf` file:

```hcl
clone = "ubuntu-cloud-template"
```

## 🌐 Tailscale VPN Installation

Install Tailscale VPN for secure mesh networking across your homelab:

```bash
# Basic installation
make tailscale-install

# With authentication key
make tailscale-install AUTHKEY=tskey-auth-xxxxx

# Check status
make tailscale-status
```

📖 **Full Documentation**: See [TAILSCALE.md](TAILSCALE.md) for complete guide  
⚡ **Quick Reference**: See [TAILSCALE_QUICKREF.md](TAILSCALE_QUICKREF.md) for commands

### Tailscale Features
- Zero-config mesh VPN
- Automatic peer-to-peer connections
- Built-in SSH access
- Subnet routing support
- Exit node capability
- DNS resolution for all nodes

## 📚 Available Playbooks

| Playbook | Description | Command |
|----------|-------------|---------|
| `create-proxmox-template.yml` | Create Ubuntu cloud-init template | `make create` |
| `destroy-proxmox-template.yml` | Remove template | `make destroy` |
| `install-tailscale.yml` | Install Tailscale VPN | `make tailscale-install` |
| `uninstall-tailscale.yml` | Remove Tailscale | `make tailscale-remove` |
| `install-rke2-cluster.yml` | Install Kubernetes | `make install-k8s` |
| `sample-hello-world.yml` | Test playbook | `make test` |

## 🛠️ Makefile Commands

Run `make help` to see all available commands, including:

**Template Management:**
- `make create` - Create Proxmox template
- `make destroy` - Destroy template
- `make update` - Update template

**Tailscale VPN:**
- `make tailscale-install` - Install Tailscale
- `make tailscale-remove` - Uninstall Tailscale
- `make tailscale-status` - Check status
- `make tailscale-ips` - Show Tailscale IPs

**Utilities:**
- `make ping` - Test connectivity
- `make list` - List VMs on Proxmox
- `make check-syntax` - Validate playbooks

## 📖 Additional Documentation

- [Tailscale Installation Guide](TAILSCALE.md) - Complete Tailscale setup and configuration
- [Tailscale Quick Reference](TAILSCALE_QUICKREF.md) - Common commands and troubleshooting

