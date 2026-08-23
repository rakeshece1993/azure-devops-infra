resource "azurerm_route_table" "route_table" {
  name                          = var.route_table_name
  location                      = var.resource_location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  tags                          = var.resource_tags
}

# Default route - send all internet traffic to firewall
resource "azurerm_route" "default_route" {
  name                   = "default-via-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

# Optional: Route to other spokes via firewall
resource "azurerm_route" "spoke_routes" {
  for_each = var.spoke_address_prefixes

  name                   = "to-${each.key}"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.route_table.name
  address_prefix         = each.value
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

# Associate route table with subnets
resource "azurerm_subnet_route_table_association" "subnet_association" {
  for_each = toset(var.subnet_ids)

  subnet_id      = each.value
  route_table_id = azurerm_route_table.route_table.id
}

