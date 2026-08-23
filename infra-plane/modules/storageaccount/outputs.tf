output "storage_account_name" {
  value       = azurerm_storage_account.storage_account.name
  description = "The name of the Storage Account"
}

output "storage_account_id" {
  value       = azurerm_storage_account.storage_account.id
  description = "The ID of the Storage Account"
}

output "storage_account_primary_access_key" {
  value       = azurerm_storage_account.storage_account.primary_access_key
  description = "The primary access key of the Storage Account"
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  value       = azurerm_storage_account.storage_account.primary_connection_string
  description = "The primary connection string of the Storage Account"
  sensitive   = true
}