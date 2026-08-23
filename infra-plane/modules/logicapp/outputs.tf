output "logic_app_id" {
  value       = azurerm_logic_app_workflow.logic_app.id
  description = "The ID of the Logic App"
}

output "logic_app_name" {
  value       = azurerm_logic_app_workflow.logic_app.name
  description = "The name of the Logic App"
}

output "logic_app_access_endpoint" {
  value       = azurerm_logic_app_workflow.logic_app.access_endpoint
  description = "The Access Endpoint of the Logic App"
}

output "logic_app_connector_endpoint_ip_addresses" {
  value       = azurerm_logic_app_workflow.logic_app.connector_endpoint_ip_addresses
  description = "The connector endpoint IP addresses"
}

output "logic_app_workflow_endpoint_ip_addresses" {
  value       = azurerm_logic_app_workflow.logic_app.workflow_endpoint_ip_addresses
  description = "The workflow endpoint IP addresses"
}

