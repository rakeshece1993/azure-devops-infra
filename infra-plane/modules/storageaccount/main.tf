resource "azurerm_storage_account" "storage_account" {
    name = var.storage_account_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    account_tier = var.account_tier
    account_replication_type = var.account_replication_type
    tags = var.resource_tags
    access_tier = var.access_tier
}