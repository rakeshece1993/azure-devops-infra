resource "azurerm_network_interface" "nic_card" {
    name = var.nic_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    ip_configuration {
        name = var.ip_config_name
        subnet_id = var.subnet_id
        private_ip_address_allocation = "Dynamic"
    }
    tags = var.resource_tags
  
}