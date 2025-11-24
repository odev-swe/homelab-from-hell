# Tailscale VPN Installation Guide

This guide covers installing and configuring Tailscale VPN on your homelab hosts using Ansible.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration Options](#configuration-options)
- [Usage Examples](#usage-examples)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)

## 🎯 Overview

Tailscale creates a secure mesh VPN network (Tailnet) across your homelab hosts, providing:

- ✅ Zero-config VPN mesh network
- ✅ End-to-end encrypted connections
- ✅ Direct peer-to-peer connectivity when possible
- ✅ Built-in SSH access
- ✅ DNS resolution for all nodes
- ✅ Cross-platform support

## 📦 Prerequisites

1. **Tailscale Account**
   - Sign up at [https://tailscale.com](https://tailscale.com)
   - Free tier includes up to 100 devices

2. **Authentication Key** (Optional but recommended)
   - Generate at [https://login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys)
   - Choose "Reusable" for multiple installs
   - Set expiration as needed

3. **Target Hosts**
   - Ubuntu/Debian based systems
   - Internet connectivity
   - Sudo privileges configured

## 🚀 Quick Start

### Basic Installation (Manual Authentication)

Install Tailscale without an auth key. You'll need to manually authenticate each node:

```bash
cd ansible
make tailscale-install
```

After installation:
1. Visit the URLs shown in the output
2. Approve each machine in your Tailscale admin console

### Automated Installation (Recommended)

Install with an auth key for automatic authentication:

```bash
# Get your auth key from: https://login.tailscale.com/admin/settings/keys
make tailscale-install AUTHKEY=tskey-auth-xxxxxxxxxxxxx
```

### Check Status

```bash
make tailscale-status
```

## ⚙️ Configuration Options

### Available Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `tailscale_auth_key` | Authentication key for auto-approval | "" | No |
| `tailscale_hostname` | Custom hostname for the node | "" | No |
| `tailscale_advertise_routes` | Subnet routes to advertise | "" | No |
| `tailscale_accept_routes` | Accept routes from other nodes | `false` | No |
| `tailscale_advertise_exit_node` | Advertise as exit node | `false` | No |
| `tailscale_accept_dns` | Accept DNS configuration | `true` | No |
| `tailscale_ssh` | Enable Tailscale SSH | `true` | No |

### Setting Variables

**Via command line:**
```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_auth_key=tskey-auth-xxxxx" \
  -e "tailscale_hostname=my-custom-name"
```

**Via group_vars/all.yml:**
```yaml
# Add to group_vars/all.yml
tailscale_auth_key: "tskey-auth-xxxxxxxxxxxxx"
tailscale_accept_dns: true
tailscale_ssh: true
```

## 📚 Usage Examples

### Example 1: Simple Installation

Install on all kubernetes hosts:

```bash
make tailscale-install AUTHKEY=tskey-auth-xxxxx
```

### Example 2: Subnet Router

Make a node advertise local network routes:

```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_auth_key=tskey-auth-xxxxx" \
  -e "tailscale_advertise_routes=192.168.100.0/24"
```

Then enable subnet routing in Tailscale admin console.

### Example 3: Exit Node

Configure a node as an exit node (for routing all traffic):

```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_auth_key=tskey-auth-xxxxx" \
  -e "tailscale_advertise_exit_node=true"
```

### Example 4: Accept Routes from Others

Configure a node to use routes advertised by other nodes:

```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_accept_routes=true"
```

### Example 5: Custom Hostname

Set a custom hostname for the node:

```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_hostname=k8s-master-homelab"
```

### Example 6: Install on Specific Host

```bash
ansible-playbook playbooks/install-tailscale.yml \
  --limit k8s-master \
  -e "tailscale_auth_key=tskey-auth-xxxxx"
```

## 🔧 Advanced Features

### Subnet Routing

Allow access to your homelab network from any Tailscale device:

1. **Configure the router:**
   ```bash
   make tailscale-install-advanced \
     AUTHKEY=tskey-auth-xxxxx \
     ROUTES=192.168.100.0/24
   ```

2. **Enable IP forwarding** (playbook handles this automatically)

3. **Approve in admin console:**
   - Go to https://login.tailscale.com/admin/machines
   - Click on the machine
   - Enable "Subnet routes"

4. **Accept routes on clients:**
   ```bash
   make tailscale-install-advanced ACCEPT_ROUTES=true
   ```

### Exit Node Setup

Route all internet traffic through your homelab:

1. **Configure exit node:**
   ```bash
   ansible-playbook playbooks/install-tailscale.yml \
     -e "tailscale_advertise_exit_node=true" \
     --limit your-exit-node
   ```

2. **Approve in admin console**

3. **Use on client:**
   ```bash
   tailscale up --exit-node=your-exit-node
   ```

### Tailscale SSH

Access hosts via Tailscale SSH (enabled by default):

```bash
# SSH via Tailscale (no keys needed)
ssh username@hostname.tailnet-name.ts.net

# Or use tailscale ssh command
tailscale ssh username@hostname
```

## 🔍 Troubleshooting

### Check Installation Status

```bash
# Via Makefile
make tailscale-status

# Via ansible directly
ansible kubernetes -m shell -a "tailscale status" -b
```

### Get Tailscale IPs

```bash
make tailscale-ips
```

### Test Connectivity

```bash
# Ping another Tailscale node
make tailscale-ping TARGET=hostname

# Or manually on a host
ssh host
tailscale ping other-hostname
```

### Common Issues

**Issue: "Tailscale not authenticated"**

Solution: Provide auth key or manually authenticate:
```bash
# On the host
sudo tailscale up
# Visit the URL shown and authenticate
```

**Issue: "Cannot resolve Tailscale hostnames"**

Solution: Ensure DNS is enabled:
```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_accept_dns=true"
```

**Issue: "Subnet routes not working"**

Solution:
1. Check route is advertised: `tailscale status`
2. Enable in admin console
3. Accept routes on clients
4. Verify IP forwarding: `cat /proc/sys/net/ipv4/ip_forward` (should be 1)

**Issue: "UFW blocking Tailscale"**

Solution: Playbook automatically adds UFW rule. Verify:
```bash
sudo ufw status | grep 41641
```

### View Logs

```bash
# On the host
sudo journalctl -u tailscaled -f

# Recent errors
sudo journalctl -u tailscaled -p err -n 50
```

### Network Diagnostics

```bash
# On the host
tailscale netcheck
```

## 🗑️ Uninstallation

### Remove Tailscale from All Hosts

```bash
make tailscale-remove
```

### Remove from Specific Host

```bash
ansible-playbook playbooks/uninstall-tailscale.yml --limit hostname
```

### Keep Configuration Files

```bash
ansible-playbook playbooks/uninstall-tailscale.yml \
  -e "remove_config=false"
```

## 📊 Monitoring & Management

### Check All Nodes Status

```bash
make tailscale-status
```

### View Tailscale IPs

```bash
make tailscale-ips
```

### Tailscale Admin Console

Manage your Tailnet at: [https://login.tailscale.com/admin](https://login.tailscale.com/admin)

Features:
- View all connected devices
- Approve subnet routers and exit nodes
- Manage ACLs (Access Control Lists)
- View connection logs
- Generate auth keys

## 🔐 Security Best Practices

1. **Use Reusable Auth Keys for Automation**
   - Set expiration dates
   - Rotate keys periodically

2. **Enable Tailscale SSH**
   - Centralized SSH key management
   - Automatic key rotation

3. **Use ACLs** 
   - Restrict access between nodes
   - Define policies in admin console

4. **Enable MFA**
   - Add 2FA to your Tailscale account

5. **Monitor Device Approvals**
   - Review new device connections regularly

## 📚 Additional Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Subnet Routers Guide](https://tailscale.com/kb/1019/subnets/)
- [Exit Nodes Guide](https://tailscale.com/kb/1103/exit-nodes/)
- [Tailscale SSH Guide](https://tailscale.com/kb/1193/tailscale-ssh/)
- [ACL Documentation](https://tailscale.com/kb/1018/acls/)

## 🎯 Next Steps

After installing Tailscale:

1. ✅ Test connectivity between nodes
   ```bash
   tailscale ping other-node
   ```

2. ✅ Set up subnet routing (optional)
3. ✅ Configure exit node (optional)
4. ✅ Enable Tailscale SSH
5. ✅ Configure ACLs for security
6. ✅ Install Tailscale on your client devices

---

**Need Help?** Check the [Troubleshooting](#troubleshooting) section or visit [Tailscale's support](https://tailscale.com/contact/support/).
