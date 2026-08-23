variable "storage_account_name" {
    type = string
    description = "Name of the storage account"
  
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "resource_location" {
    type = string
    description = "Azure region for the resource group"
}
variable "account_tier" {
    type = string
    description = "Account tier for the storage account"
}
variable "account_replication_type" {
    type = string
    description = "Account replication type for the storage account"
}
variable "resource_tags" {
    type = map(string)
    description = "Tags for the resource group"
}
variable "access_tier" {
    type = string
    description = "Access tier for the storage account"
}
