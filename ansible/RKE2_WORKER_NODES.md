# 🔧 Adding Worker Nodes to RKE2 Cluster

Complete guide for adding worker nodes to your RKE2 Kubernetes cluster.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Step-by-Step Guide](#step-by-step-guide)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Scaling](#scaling)

## 🎯 Overview

This guide covers the complete process of adding worker nodes to your existing RKE2 cluster:

1. **Create VM** with Terraform
2. **Update Inventory** to include the worker
3. **Join Worker** to the cluster with Ansible
4. **Verify** the worker is functioning

## 📦 Prerequisites

- ✅ RKE2 master node installed and running
- ✅ Proxmox VM template created
- ✅ Network connectivity between nodes
- ✅ SSH access to all nodes

## 🚀 Step-by-Step Guide

### Step 1: Create Worker VM with Terraform

**Edit `terraform/cred.auto.tfvars`:**

```hcl
vm_configs = {
  "master-node" = {
    vm_id       = 102
    name        = "master-node"
    memory      = 8192
    cores       = 8
    disk_size   = "100G"
    vm_state    = "running"
    onboot      = true
    startup     = "order=2"
    ipconfig    = "ip=192.168.100.100/24,gw=192.168.100.1"
    ciuser      = "masternode"
    bridge      = "vmbr0"
    network_tag = 0
    tags        = ["kubernetes", "master"]
    description = "Kubernetes Master Node"
  }
  
  # Add worker nodes here
  "worker-node-1" = {
    vm_id       = 103
    name        = "worker-node-1"
    memory      = 8192
    cores       = 8
    disk_size   = "100G"
    vm_state    = "running"
    onboot      = true
    startup     = "order=3"
    ipconfig    = "ip=192.168.100.101/24,gw=192.168.100.1"
    ciuser      = "masternode"
    bridge      = "vmbr0"
    network_tag = 0
    tags        = ["kubernetes", "worker"]
    description = "Kubernetes Worker Node 1"
  }
  
  # Optional: Add more workers
  "worker-node-2" = {
    vm_id       = 104
    name        = "worker-node-2"
    memory      = 8192
    cores       = 8
    disk_size   = "100G"
    vm_state    = "running"
    onboot      = true
    startup     = "order=4"
    ipconfig    = "ip=192.168.100.102/24,gw=192.168.100.1"
    ciuser      = "masternode"
    bridge      = "vmbr0"
    network_tag = 0
    tags        = ["kubernetes", "worker"]
    description = "Kubernetes Worker Node 2"
  }
}
```

**Apply Terraform changes:**

```bash
cd terraform
tofu plan
tofu apply
```

### Step 2: Update Ansible Inventory

**Edit `ansible/inventory/hosts.yml`:**

```yaml
---
all:
  children:
    proxmox:
      hosts:
        pve:
          ansible_host: "192.168.100.10"
          ansible_user: root
          ansible_ssh_private_key_file: ~/.ssh/homelab
    
    kubernetes:
      children:
        k8s_master:
          hosts:
            k8s-master:
              ansible_host: "192.168.100.100"
              ansible_user: masternode
              ansible_ssh_private_key_file: ~/.ssh/homelab
        
        k8s_workers:
          hosts:
            k8s-worker-1:
              ansible_host: "192.168.100.101"
              ansible_user: masternode
              ansible_ssh_private_key_file: ~/.ssh/homelab
            
            k8s-worker-2:
              ansible_host: "192.168.100.102"
              ansible_user: masternode
              ansible_ssh_private_key_file: ~/.ssh/homelab
```

**Test connectivity:**

```bash
cd ansible
ansible k8s_workers -m ping
```

### Step 3: Join Workers to Cluster

**Option A: Join all workers at once**

```bash
cd ansible
make join-workers
```

**Option B: Join specific worker**

```bash
make join-worker NODE=k8s-worker-1
```

**Option C: Using ansible-playbook directly**

```bash
ansible-playbook playbooks/join-rke2-workers.yml

# Or for specific worker
ansible-playbook playbooks/join-rke2-workers.yml --limit k8s-worker-1
```

### Step 4: Verify the Cluster

**Check all nodes:**

```bash
# On master node
ssh masternode@192.168.100.100
kubectl get nodes -o wide
```

Expected output:
```
NAME            STATUS   ROLES                       AGE   VERSION
master-node     Ready    control-plane,master        1d    v1.28.x+rke2
worker-node-1   Ready    worker                      5m    v1.28.x+rke2
worker-node-2   Ready    worker                      5m    v1.28.x+rke2
```

**Check node labels:**

```bash
kubectl get nodes --show-labels
```

**Check system pods:**

```bash
kubectl get pods -n kube-system -o wide
```

## ✅ Verification Checklist

- [ ] Worker VMs created and running
- [ ] Ansible can ping workers
- [ ] Worker nodes appear in `kubectl get nodes`
- [ ] Worker nodes status is `Ready`
- [ ] System pods running on workers
- [ ] Worker nodes have correct labels
- [ ] Network connectivity between nodes working

## 🔍 Troubleshooting

### Worker Node Not Appearing

**Check RKE2 agent service:**
```bash
ssh masternode@192.168.100.101
sudo systemctl status rke2-agent
sudo journalctl -u rke2-agent -f
```

**Check connection to master:**
```bash
# On worker node
sudo journalctl -u rke2-agent | grep -i error
```

**Verify token:**
```bash
# On master
sudo cat /var/lib/rancher/rke2/server/node-token

# On worker
sudo cat /etc/rancher/rke2/config.yaml
```

### Worker Node in NotReady State

**Check kubelet:**
```bash
# On master
kubectl describe node worker-node-1
kubectl get events -n kube-system
```

**Check CNI (Cilium):**
```bash
kubectl get pods -n kube-system -l k8s-app=cilium -o wide
```

**Restart agent:**
```bash
# On worker
sudo systemctl restart rke2-agent
```

### Network Issues

**Test connectivity:**
```bash
# From master
ping 192.168.100.101

# Test port 9345 (RKE2 server port)
nc -zv 192.168.100.100 9345
```

**Check firewall:**
```bash
# On all nodes
sudo ufw status

# Required ports:
# Master: 9345 (server), 6443 (API), 10250 (kubelet)
# Workers: 10250 (kubelet)
```

### Re-join Worker Node

If you need to re-join a worker:

```bash
# On worker node
sudo systemctl stop rke2-agent
sudo rm -rf /var/lib/rancher/rke2/agent

# On master, remove the node
kubectl delete node worker-node-1

# Re-run the join playbook
cd ansible
make join-worker NODE=k8s-worker-1
```

## 📈 Scaling Your Cluster

### Adding Multiple Workers

1. **Plan your resources:**
   - Minimum per worker: 2GB RAM, 2 CPU cores, 20GB disk
   - Recommended: 8GB RAM, 4 CPU cores, 100GB disk

2. **Add VMs incrementally:**
   ```bash
   # Add one worker at a time
   cd terraform
   # Edit cred.auto.tfvars (add worker-node-3)
   tofu apply
   
   # Update inventory
   # Edit ansible/inventory/hosts.yml
   
   # Join to cluster
   cd ansible
   make join-worker NODE=k8s-worker-3
   ```

3. **Verify after each addition:**
   ```bash
   kubectl get nodes
   kubectl get pods -A -o wide
   ```

### Worker Node Sizing Guidelines

| Workload Type | RAM | CPU | Disk | Nodes |
|---------------|-----|-----|------|-------|
| Development | 4GB | 2 | 50GB | 1-2 |
| Small Production | 8GB | 4 | 100GB | 2-3 |
| Medium Production | 16GB | 8 | 200GB | 3-5 |
| Large Production | 32GB | 16 | 500GB | 5+ |

### Best Practices

1. **Label workers by function:**
   ```bash
   kubectl label node worker-node-1 workload=compute
   kubectl label node worker-node-2 workload=storage
   ```

2. **Taint nodes for dedicated workloads:**
   ```bash
   kubectl taint nodes worker-node-1 dedicated=gpu:NoSchedule
   ```

3. **Use node affinity for placement:**
   ```yaml
   affinity:
     nodeAffinity:
       requiredDuringSchedulingIgnoredDuringExecution:
         nodeSelectorTerms:
         - matchExpressions:
           - key: workload
             operator: In
             values:
             - compute
   ```

## 🎯 Quick Reference

### Common Commands

```bash
# List all nodes
kubectl get nodes

# Get node details
kubectl describe node worker-node-1

# Cordon node (prevent new pods)
kubectl cordon worker-node-1

# Drain node (move pods, maintenance)
kubectl drain worker-node-1 --ignore-daemonsets

# Uncordon node (allow scheduling)
kubectl uncordon worker-node-1

# Remove node from cluster
kubectl delete node worker-node-1

# Get pods on specific node
kubectl get pods -A -o wide --field-selector spec.nodeName=worker-node-1

# SSH to worker
ssh masternode@192.168.100.101

# Check agent logs
sudo journalctl -u rke2-agent -f
```

### Ansible Commands

```bash
# Join all workers
make join-workers

# Join specific worker
make join-worker NODE=k8s-worker-1

# Check connectivity
ansible k8s_workers -m ping

# Run command on all workers
ansible k8s_workers -m shell -a "uptime" -b
```

### Terraform Commands

```bash
# Plan changes
cd terraform
tofu plan

# Apply changes
tofu apply

# Show outputs
tofu output

# Destroy specific worker
tofu destroy -target='proxmox_vm_qemu.vms["worker-node-1"]'
```

## 📚 Additional Resources

- [RKE2 Documentation](https://docs.rke2.io/)
- [Kubernetes Node Management](https://kubernetes.io/docs/concepts/architecture/nodes/)
- [Cilium Network Policies](https://docs.cilium.io/en/stable/)

---

**Need help?** Check the troubleshooting section or review the playbook logs for detailed error messages.
