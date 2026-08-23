resource "azurerm_virtual_network" "virtual_network" {
    name = var.vnet_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    address_space = var.address_space
    tags = var.resource_tags
}
