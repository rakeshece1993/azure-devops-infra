output "network_security_group_id_output" {
    value = azurerm_network_security_group.nsg.id
    description = "The ID of the network security group"
  
}