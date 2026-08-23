variable "firewall_policy_name" {
  type        = string
  description = "Name of the Azure Firewall Policy"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "resource_location" {
  type        = string
  description = "Azure region for the resources"
}

variable "firewall_policy_sku" {
  type        = string
  description = "SKU of the Firewall Policy (Standard or Premium)"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_policy_sku)
    error_message = "Firewall Policy SKU must be either 'Standard' or 'Premium'."
  }
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags to apply to the resources"
  default     = {}
}

variable "app_ip_ranges" {
  type        = list(string)
  description = "List of IP CIDR ranges for application tier"
  default     = ["10.0.1.0/24"]
}

variable "mgmt_ip_ranges" {
  type        = list(string)
  description = "List of IP CIDR ranges for management tier"
  default     = ["10.0.0.0/24"]
}

variable "aks_region" {
  type        = string
  description = "Azure region where AKS is deployed (for control plane FQDNs)"
  default     = "eastus"
}

