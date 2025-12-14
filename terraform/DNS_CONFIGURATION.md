# DNS Configuration Guide

## Overview

Custom DNS servers can be configured for your VMs using the `nameserver` parameter in cloud-init configuration.

## Default Configuration

By default, all VMs use Google's public DNS servers:
```
nameserver = "8.8.8.8 8.8.4.4"
```

## Custom DNS Servers

### Method 1: Per-VM Configuration

Add the `nameserver` parameter to specific VMs in `cred.auto.tfvars`:

```hcl
vm_configs = {
  "master-node" = {
    vm_id       = 102
    name        = "master-node"
    ipconfig    = "ip=192.168.100.100/24,gw=192.168.100.1"
    ciuser      = "masternode"
    nameserver  = "192.168.100.1"  # Use your router/gateway as DNS
    # ... other settings
  }
}
```

### Method 2: Change Global Default

Edit `variable.tf` to change the default for all VMs:

```hcl
variable "vm_defaults" {
  # ...
  default = {
    # ...
    nameserver  = "192.168.100.1"  # Your preferred DNS server
    # ...
  }
}
```

## Common DNS Server Examples

### Home Router (Local DNS)
```hcl
nameserver = "192.168.100.1"
```

### Google Public DNS
```hcl
nameserver = "8.8.8.8 8.8.4.4"
```

### Cloudflare DNS
```hcl
nameserver = "1.1.1.1 1.0.0.1"
```

### Quad9 DNS (Privacy-focused)
```hcl
nameserver = "9.9.9.9 149.112.112.112"
```

### OpenDNS
```hcl
nameserver = "208.67.222.222 208.67.220.220"
```

### Multiple DNS Servers (Primary + Secondary)
```hcl
nameserver = "192.168.100.1 8.8.8.8"  # Local first, then Google
```

### Pi-hole or AdGuard Home
```hcl
nameserver = "192.168.100.5"  # Your Pi-hole IP
```

## Configuration Format

The `nameserver` parameter accepts:
- **Single DNS**: `"8.8.8.8"`
- **Multiple DNS** (space-separated): `"8.8.8.8 8.8.4.4"`
- **Up to 3 servers**: `"8.8.8.8 8.8.4.4 1.1.1.1"`

## Example: Mixed Configuration

```hcl
vm_configs = {
  # Master node uses local DNS for service discovery
  "master-node" = {
    vm_id      = 102
    name       = "master-node"
    nameserver = "192.168.100.1 8.8.8.8"  # Local first, fallback to Google
    # ... other settings
  }
  
  # Worker nodes use Cloudflare for faster external resolution
  "worker-node-1" = {
    vm_id      = 103
    name       = "worker-node-1"
    nameserver = "1.1.1.1 1.0.0.1"  # Cloudflare DNS
    # ... other settings
  }
  
  # Database server uses only local DNS
  "db-node" = {
    vm_id      = 104
    name       = "db-node"
    nameserver = "192.168.100.1"  # Only local DNS
    # ... other settings
  }
}
```

## Applying Changes

After updating DNS configuration:

```bash
cd terraform
tofu plan   # Review changes
tofu apply  # Apply changes
```

**Note**: Changing DNS on existing VMs requires recreating them or manually updating `/etc/resolv.conf` inside the VM.

## Verification

After VM creation, verify DNS configuration:

```bash
# SSH into the VM
ssh masternode@192.168.100.100

# Check DNS configuration
cat /etc/resolv.conf

# Should show:
# nameserver 192.168.100.1
# nameserver 8.8.8.8

# Test DNS resolution
nslookup google.com
dig google.com
```

## Troubleshooting

### DNS Not Working

1. **Check cloud-init applied correctly:**
   ```bash
   sudo cat /var/lib/cloud/instance/user-data.txt | grep nameserver
   ```

2. **Check resolv.conf:**
   ```bash
   cat /etc/resolv.conf
   ```

3. **Test DNS manually:**
   ```bash
   nslookup google.com 8.8.8.8
   ```

### DNS Overwritten by DHCP

If using DHCP (`ip=dhcp`) and DNS gets overwritten:

1. **Configure in Proxmox GUI:**
   - Go to VM → Options → Cloud-Init
   - Set DNS servers there

2. **Or use static IP with DNS:**
   ```hcl
   ipconfig    = "ip=192.168.100.100/24,gw=192.168.100.1"
   nameserver  = "192.168.100.1 8.8.8.8"
   ```

### Multiple DNS Servers Not Working

Ensure they're **space-separated**, not comma-separated:

✅ **Correct:**
```hcl
nameserver = "8.8.8.8 8.8.4.4"
```

❌ **Incorrect:**
```hcl
nameserver = "8.8.8.8,8.8.4.4"
```

## Best Practices

1. **Use Local DNS First**: Set your local router/DNS server as primary for internal name resolution
   ```hcl
   nameserver = "192.168.100.1 8.8.8.8"
   ```

2. **Always Have a Fallback**: Include a public DNS as secondary
   ```hcl
   nameserver = "192.168.100.1 1.1.1.1"  # Local + Cloudflare fallback
   ```

3. **Test DNS Performance**: Use `namebench` or `dnsperf` to find fastest DNS for your location

4. **Security Considerations**: 
   - Use DNS-over-HTTPS (DoH) capable servers like Cloudflare/Quad9
   - Consider Pi-hole for ad-blocking at DNS level
   - Avoid public DNS if handling sensitive internal names

5. **Kubernetes Considerations**:
   - Ensure nodes can resolve each other's hostnames
   - Consider using local DNS for service discovery
   - CoreDNS in Kubernetes handles internal DNS

## Integration with RKE2/Kubernetes

For Kubernetes clusters, ensure proper DNS:

```hcl
vm_configs = {
  "master-node" = {
    vm_id      = 102
    nameserver = "192.168.100.1 8.8.8.8"  # Can resolve other nodes
    # ...
  }
  
  "worker-node" = {
    vm_id      = 103  
    nameserver = "192.168.100.1 8.8.8.8"  # Same DNS for consistency
    # ...
  }
}
```

This ensures:
- Nodes can resolve each other by hostname
- External DNS queries work (for pulling images, etc.)
- Internal service discovery works properly

---

**For more information**: See [Proxmox Cloud-Init Documentation](https://pve.proxmox.com/wiki/Cloud-Init_Support)
