output "function_app_id" {
  value       = azurerm_linux_function_app.function_app.id
  description = "The ID of the Function App"
}

output "function_app_name" {
  value       = azurerm_linux_function_app.function_app.name
  description = "The name of the Function App"
}

output "function_app_default_hostname" {
  value       = azurerm_linux_function_app.function_app.default_hostname
  description = "The default hostname of the Function App"
}

output "function_app_outbound_ip_addresses" {
  value       = azurerm_linux_function_app.function_app.outbound_ip_addresses
  description = "The outbound IP addresses of the Function App"
}

output "function_app_possible_outbound_ip_addresses" {
  value       = azurerm_linux_function_app.function_app.possible_outbound_ip_addresses
  description = "The possible outbound IP addresses of the Function App"
}

