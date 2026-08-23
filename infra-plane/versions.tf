
terraform {
  required_version = ">= 1.9"
  backend "azurerm" {

    subscription_id      = "7ef34a6b-6b1e-4d5b-a67f-ff80315f5991"
    resource_group_name  = "tekionrg"
    storage_account_name = "tekion"
    container_name       = "tinfra"
    key                  = "dev2.terraform.tfstate"


  }
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">=2.0, < 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.48.0, < 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1"
    }
  }
}




provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = "7ef34a6b-6b1e-4d5b-a67f-ff80315f5991"
  features {}
}

module "deploy_env" {
  source            = "./environments/dev/"
  environment_name  = "dev"
  platform_name     = "aec"
  program_name      = "gm"
  module_name       = "cx"
  resource_location = "westus2"
  spoke_cidr_prefix = "10.31.32.0/19"
  custom_tags = {
    deployedBy = "rakeshk@tekion.com"
  }
}




# module "firewall_policy" {
#   source = "./modules/hubnet/firewall/"

#   firewall_policy_name = "prod-aec-eastus-fw-policy"
#   resource_group_name  = "aec-mlt-eastus-rg"
#   resource_location    = "eastus"
#   firewall_policy_sku  = "Standard"

#   # Define IP ranges for your application and management tiers
#   app_ip_ranges  = ["10.51.128.0/20"]  # AKS VNet CIDR
#   mgmt_ip_ranges = ["10.51.3.64/26"]   # Bastion subnet CIDR

#   # AKS region for control plane FQDNs
#   aks_region = "eastus"  # Update to match your AKS region

#   resource_tags = {
#     environment = "prod"
#     platform    = "aec"
#     project     = "mlt"
#     managedBy   = "Terraform"
#     deployedBy  = "rakeshk@tekion.com"
#   }
# }





