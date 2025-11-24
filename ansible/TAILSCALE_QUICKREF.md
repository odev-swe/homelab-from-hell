# 🚀 Tailscale Quick Reference

## Common Commands

### Installation
```bash
# Basic install (manual auth)
make tailscale-install

# Install with auto-auth
make tailscale-install AUTHKEY=tskey-auth-xxxxx

# Install on specific host
ansible-playbook playbooks/install-tailscale.yml --limit hostname -e "tailscale_auth_key=xxx"
```

### Status & Monitoring
```bash
make tailscale-status        # Check status on all hosts
make tailscale-ips           # Get Tailscale IPs
make tailscale-ping TARGET=host  # Test connectivity
```

### Management
```bash
make tailscale-remove        # Uninstall from all hosts
```

## On-Host Commands

```bash
# Status
tailscale status             # Show connection status
tailscale status --json      # JSON output
tailscale ip                 # Show Tailscale IPs
tailscale netcheck           # Network diagnostics

# Connectivity
tailscale ping hostname      # Ping another node

# Configuration
tailscale up                 # Connect to Tailnet
tailscale up --accept-routes # Accept subnet routes
tailscale up --exit-node=X   # Use exit node
tailscale down               # Disconnect
tailscale logout             # Logout from Tailnet

# SSH
tailscale ssh user@hostname  # SSH via Tailscale

# Debugging
sudo journalctl -u tailscaled -f    # View logs
tailscale version            # Show version
```

## Auth Key Generation

1. Visit: https://login.tailscale.com/admin/settings/keys
2. Click "Generate auth key"
3. Select options:
   - ✅ Reusable (for multiple installs)
   - ✅ Ephemeral (optional - auto-cleanup)
   - Set expiration
4. Copy key: `tskey-auth-xxxxxxxxxxxxx`

## Subnet Router Setup

```bash
# 1. Install with route advertisement
make tailscale-install-advanced \
  AUTHKEY=tskey-auth-xxx \
  ROUTES=192.168.100.0/24

# 2. Approve in admin console:
#    https://login.tailscale.com/admin/machines
#    Click machine → Enable "Subnet routes"

# 3. Accept routes on clients
make tailscale-install-advanced ACCEPT_ROUTES=true
```

## Exit Node Setup

```bash
# 1. Configure exit node
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_advertise_exit_node=true" \
  --limit your-exit-node

# 2. Approve in admin console

# 3. Use on client
tailscale up --exit-node=your-exit-node
```

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `tailscale_auth_key` | "" | Auth key for auto-approval |
| `tailscale_hostname` | "" | Custom hostname |
| `tailscale_advertise_routes` | "" | Routes to advertise (e.g., "192.168.0.0/24") |
| `tailscale_accept_routes` | false | Accept routes from others |
| `tailscale_advertise_exit_node` | false | Advertise as exit node |
| `tailscale_accept_dns` | true | Accept DNS config |
| `tailscale_ssh` | true | Enable Tailscale SSH |

## Troubleshooting

```bash
# Check if running
systemctl status tailscaled

# View logs
sudo journalctl -u tailscaled -n 100

# Restart service
sudo systemctl restart tailscaled

# Re-authenticate
sudo tailscale logout
sudo tailscale up

# Network diagnostics
tailscale netcheck

# Ping test
tailscale ping hostname
```

## Useful Links

- Admin Console: https://login.tailscale.com/admin
- Generate Keys: https://login.tailscale.com/admin/settings/keys
- Documentation: https://tailscale.com/kb/
- ACL Editor: https://login.tailscale.com/admin/acls

## File Locations

```
/usr/bin/tailscale          # CLI binary
/usr/sbin/tailscaled        # Daemon
/var/lib/tailscale/         # State directory
/etc/default/tailscaled     # Configuration
```

## Security Checklist

- [ ] Use auth keys with expiration
- [ ] Enable MFA on Tailscale account
- [ ] Configure ACLs for node access
- [ ] Enable Tailscale SSH
- [ ] Review device approvals regularly
- [ ] Rotate auth keys periodically
- [ ] Use subnet routes instead of exposing nodes
- [ ] Monitor connection logs

## Integration Examples

### Access Homelab from Anywhere
```bash
# 1. Set up subnet router on gateway node
make tailscale-install-advanced \
  AUTHKEY=xxx ROUTES=192.168.100.0/24

# 2. Enable in admin console
# 3. Install Tailscale on laptop/phone
# 4. Access homelab: http://192.168.100.x
```

### Kubernetes API Access
```bash
# Access k8s master from anywhere via Tailnet
export KUBECONFIG=~/.kube/config
kubectl --server=https://master-node.tailnet.ts.net:6443 get nodes
```

### Secure Remote Access
```bash
# SSH via Tailscale
ssh user@hostname.tailnet.ts.net

# Or use Tailscale SSH
tailscale ssh user@hostname
```
