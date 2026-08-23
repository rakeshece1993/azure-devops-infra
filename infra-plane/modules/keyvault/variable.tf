variable "key_vault_name" {
    type = string
    description = "Name of the key vault"
  
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "resource_location" {
    type = string
    description = "Azure region for the resource group"
}

variable "key_vault_sku" {
    type = string
    description = "SKU of the key vault"
}

variable "resource_tags" {
    type = map(string)
    description = "Tags to apply to the resources"
    default = {}
}
