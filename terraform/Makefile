.PHONY: help init plan apply destroy validate fmt clean refresh output state-list

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Terraform/OpenTofu Management Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

init: ## Initialize Terraform/OpenTofu
	@echo "$(BLUE)Initializing OpenTofu...$(NC)"
	tofu init
	@echo "$(GREEN)✓ Initialization complete$(NC)"

validate: ## Validate configuration files
	@echo "$(BLUE)Validating configuration...$(NC)"
	tofu validate
	@echo "$(GREEN)✓ Configuration is valid$(NC)"

fmt: ## Format all Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	tofu fmt -recursive
	@echo "$(GREEN)✓ Files formatted$(NC)"

plan: ## Show execution plan
	@echo "$(BLUE)Generating execution plan...$(NC)"
	tofu plan

plan-destroy: ## Show destruction plan
	@echo "$(YELLOW)Generating destruction plan...$(NC)"
	tofu plan -destroy

apply: ## Apply changes
	@echo "$(BLUE)Applying changes...$(NC)"
	tofu apply

apply-auto: ## Apply changes without confirmation
	@echo "$(YELLOW)Applying changes automatically...$(NC)"
	tofu apply -auto-approve

destroy: ## Destroy all resources
	@echo "$(YELLOW)⚠️  Destroying infrastructure...$(NC)"
	tofu destroy

destroy-auto: ## Destroy all resources without confirmation
	@echo "$(YELLOW)⚠️  Destroying infrastructure automatically...$(NC)"
	tofu destroy -auto-approve

refresh: ## Refresh state
	@echo "$(BLUE)Refreshing state...$(NC)"
	tofu refresh

output: ## Show all outputs
	@echo "$(BLUE)Terraform Outputs:$(NC)"
	@tofu output

output-json: ## Show outputs in JSON format
	@tofu output -json

state-list: ## List all resources in state
	@echo "$(BLUE)Resources in state:$(NC)"
	@tofu state list

state-show: ## Show detailed state of a resource (usage: make state-show RESOURCE=proxmox_vm_qemu.vms[\"vm-1\"])
	@if [ -z "$(RESOURCE)" ]; then \
		echo "$(YELLOW)Usage: make state-show RESOURCE=proxmox_vm_qemu.vms[\\\"vm-1\\\"]$(NC)"; \
		exit 1; \
	fi
	@tofu state show '$(RESOURCE)'

vm-ips: ## Show VM IP addresses
	@echo "$(BLUE)VM IP Addresses:$(NC)"
	@tofu output -json vm_ipv4_addresses | jq -r 'to_entries[] | "\(.key): \(.value)"'

vm-ssh: ## Show VM SSH connection strings
	@echo "$(BLUE)VM SSH Connections:$(NC)"
	@tofu output -json vm_ssh_hosts | jq -r 'to_entries[] | "\(.key): ssh \(.value)"'

summary: ## Show configuration summary
	@echo "$(BLUE)Configuration Summary:$(NC)"
	@tofu output -json configuration_summary | jq .

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f crash.log
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

upgrade: ## Upgrade provider versions
	@echo "$(BLUE)Upgrading providers...$(NC)"
	tofu init -upgrade

check: fmt validate ## Run format and validation checks
	@echo "$(GREEN)✓ All checks passed$(NC)"

full-deploy: init validate plan apply ## Complete deployment workflow
	@echo "$(GREEN)✓ Full deployment complete$(NC)"

# Advanced targets
graph: ## Generate dependency graph (requires graphviz)
	@echo "$(BLUE)Generating dependency graph...$(NC)"
	tofu graph | dot -Tsvg > graph.svg
	@echo "$(GREEN)✓ Graph saved to graph.svg$(NC)"

console: ## Open Terraform console
	@echo "$(BLUE)Opening Terraform console (type 'exit' to quit)...$(NC)"
	tofu console

import: ## Import existing resource (usage: make import ADDR=proxmox_vm_qemu.vms[\"vm-1\"] ID=pve/qemu/102)
	@if [ -z "$(ADDR)" ] || [ -z "$(ID)" ]; then \
		echo "$(YELLOW)Usage: make import ADDR=proxmox_vm_qemu.vms[\\\"vm-1\\\"] ID=pve/qemu/102$(NC)"; \
		exit 1; \
	fi
	@tofu import '$(ADDR)' '$(ID)'

unlock: ## Unlock state (usage: make unlock LOCK_ID=<id>)
	@if [ -z "$(LOCK_ID)" ]; then \
		echo "$(YELLOW)Usage: make unlock LOCK_ID=<lock_id>$(NC)"; \
		exit 1; \
	fi
	@tofu force-unlock $(LOCK_ID)

docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@command -v terraform-docs >/dev/null 2>&1 || { echo "$(YELLOW)terraform-docs not installed. Install from https://terraform-docs.io/$(NC)"; exit 1; }
	terraform-docs markdown table . > TERRAFORM.md
	@echo "$(GREEN)✓ Documentation saved to TERRAFORM.md$(NC)"
