.PHONY: help create destroy test list ping check-syntax tailscale-install tailscale-remove tailscale-status

# Default target
help:
	@echo "Available targets:"
	@echo ""
	@echo "Connectivity & Testing:"
	@echo "  make ping              - Test connectivity to hosts"
	@echo "  make test              - Run hello world test playbook"
	@echo "  make list              - List all VMs and templates on Proxmox"
	@echo ""
	@echo "Template Management:"
	@echo "  make create            - Create Proxmox VM template"
	@echo "  make destroy           - Destroy Proxmox VM template"
	@echo "  make update            - Update and upgrade template"
	@echo ""
	@echo "Kubernetes:"
	@echo "  make install-k8s       - Install RKE2 Kubernetes cluster (master)"
	@echo "  make join-workers      - Join worker nodes to RKE2 cluster"
	@echo ""
	@echo "Tailscale VPN:"
	@echo "  make tailscale-install - Install Tailscale on kubernetes hosts"
	@echo "  make tailscale-remove  - Uninstall Tailscale from hosts"
	@echo "  make tailscale-status  - Check Tailscale status on all hosts"
	@echo ""
	@echo "Utilities:"
	@echo "  make check-syntax      - Check playbook syntax"
	@echo "  make clean             - Clean up temporary files"
	@echo ""

# Test connectivity
ping:
	@echo "Testing connection to Proxmox..."
	ansible -i inventory/hosts.yml proxmox -m ping

# Run hello world test
test:
	@echo "Running hello world test..."
	ansible-playbook playbooks/sample-hello-world.yml

# List VMs and templates
list:
	@echo "Listing all VMs and templates..."
	ansible proxmox -i inventory/hosts.yml -m shell -a "qm list"

# Create template
create:
	@echo "Creating Proxmox VM template..."
	ansible-playbook playbooks/create-proxmox-template.yml

# Destroy template
destroy:
	@echo "Destroying Proxmox VM template..."
	ansible-playbook playbooks/destroy-proxmox-template.yml

# Update to date template
update:
	@echo "Updating and upgrading Proxmox VM..."
	ansible-playbook playbooks/utd-template.yml

# Check syntax of all playbooks
check-syntax:
	@echo "Checking syntax of playbooks..."
	@for playbook in playbooks/*.yml; do \
		echo "Checking $$playbook..."; \
		ansible-playbook --syntax-check $$playbook; \
	done

# Install RKE2 cluster for kubernetes hosts
install-k8s:
	@echo "Installing RKE2 Kubernetes cluster (master node)..."
	ansible-playbook playbooks/install-rke2-cluster.yml

# Join worker nodes to RKE2 cluster
join-workers:
	@echo "Joining worker nodes to RKE2 cluster..."
	ansible-playbook playbooks/join-rke2-workers.yml

# Join specific worker node
join-worker:
	@echo "Usage: make join-worker NODE=k8s-worker-1"
	@if [ -z "$(NODE)" ]; then \
		echo "Error: Please specify NODE=<hostname>"; \
		exit 1; \
	fi
	@ansible-playbook playbooks/join-rke2-workers.yml --limit $(NODE)

# Remove worker nodes from cluster
remove-workers:
	@echo "Removing worker nodes from RKE2 cluster..."
	@echo "⚠️  This will drain, delete, and uninstall RKE2 from all worker nodes!"
	@ansible-playbook playbooks/remove-rke2-workers.yml

# Remove specific worker node
remove-worker:
	@echo "Usage: make remove-worker NODE=k8s-worker-1"
	@if [ -z "$(NODE)" ]; then \
		echo "Error: Please specify NODE=<hostname>"; \
		exit 1; \
	fi
	@echo "⚠️  This will remove $(NODE) from the cluster!"
	@ansible-playbook playbooks/remove-rke2-workers.yml --limit $(NODE)

# Remove workers without confirmation (use with caution!)
remove-workers-force:
	@echo "Force removing worker nodes from RKE2 cluster..."
	@ansible-playbook playbooks/remove-rke2-workers.yml -e "confirm_removal=yes"

# Clean up orphaned/NotReady nodes from cluster
cleanup-nodes:
	@echo "Cleaning up orphaned nodes from cluster..."
	@ansible-playbook playbooks/cleanup-orphaned-nodes.yml

# Clean up orphaned nodes without confirmation
cleanup-nodes-force:
	@echo "Force cleaning up orphaned nodes..."
	@ansible-playbook playbooks/cleanup-orphaned-nodes.yml -e "confirm_cleanup=yes"

# =============================================================================
# Tailscale VPN Management
# =============================================================================

# Install Tailscale on all kubernetes hosts
tailscale-install:
	@echo "Installing Tailscale on kubernetes hosts..."
	@echo "Note: Provide auth key with: make tailscale-install AUTHKEY=tskey-auth-xxxxx"
	@if [ -n "$(AUTHKEY)" ]; then \
		ansible-playbook playbooks/install-tailscale.yml -e "tailscale_auth_key=$(AUTHKEY)"; \
	else \
		ansible-playbook playbooks/install-tailscale.yml; \
	fi

# Install Tailscale with custom options
tailscale-install-advanced:
	@echo "Installing Tailscale with custom configuration..."
	@echo "Usage: make tailscale-install-advanced AUTHKEY=xxx ROUTES=192.168.0.0/24 ACCEPT_ROUTES=true"
	@ansible-playbook playbooks/install-tailscale.yml \
		$(if $(AUTHKEY),-e "tailscale_auth_key=$(AUTHKEY)") \
		$(if $(ROUTES),-e "tailscale_advertise_routes=$(ROUTES)") \
		$(if $(ACCEPT_ROUTES),-e "tailscale_accept_routes=$(ACCEPT_ROUTES)") \
		$(if $(EXIT_NODE),-e "tailscale_advertise_exit_node=$(EXIT_NODE)") \
		$(if $(HOSTNAME),-e "tailscale_hostname=$(HOSTNAME)")

# Uninstall Tailscale from all hosts
tailscale-remove:
	@echo "⚠️  Warning: This will remove Tailscale from all kubernetes hosts"
	@ansible-playbook playbooks/uninstall-tailscale.yml

# Check Tailscale status on all hosts
tailscale-status:
	@echo "Checking Tailscale status on all hosts..."
	@ansible kubernetes -i inventory/hosts.yml -m shell -a "tailscale status" -b

# Check Tailscale IPs
tailscale-ips:
	@echo "Getting Tailscale IP addresses..."
	@ansible kubernetes -i inventory/hosts.yml -m shell -a "tailscale ip -4" -b

# Test Tailscale connectivity
tailscale-ping:
	@echo "Testing Tailscale connectivity..."
	@echo "Usage: make tailscale-ping TARGET=hostname"
	@if [ -z "$(TARGET)" ]; then \
		echo "Error: Please specify TARGET=hostname"; \
		exit 1; \
	fi
	@ansible kubernetes -i inventory/hosts.yml -m shell -a "tailscale ping $(TARGET)" -b

# =============================================================================
# Utilities
# =============================================================================

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.retry" -delete
	@rm -rf .ansible
	@echo "Done!"
