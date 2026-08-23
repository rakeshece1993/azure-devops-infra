output "resource_group_name_output" {
    value       = azurerm_resource_group.resource_group.name
    description = "The name of the Resource Group"
  
}
output "resource_group_location_output" {
    value       = azurerm_resource_group.resource_group.location
    description = "The ID of the Resource Group"
  
}