output "network_interface_id_output" {
    value = azurerm_network_interface.nic_card.id
    description = "The ID of the network interface"
  
}