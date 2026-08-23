output "spoke_virtual_netowrk_name_output" {
    value = azurerm_virtual_network.virtual_network.name
    description = "Name of the spoke virtual network"
  
}