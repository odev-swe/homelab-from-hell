terraform {
  required_version = ">= 1.0"
  
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc05"  # Using RC version until stable 3.0 is released
    }
  }  # Optional: Configure remote backend for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "homelab/proxmox/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token
  pm_tls_insecure     = var.proxmox_tls_insecure
  pm_debug            = var.proxmox_debug
  pm_timeout          = 600
  pm_parallel         = 2
}