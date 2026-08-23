resource azurerm_cosmosdb_account "cosmos_account" {
    name = var.cosmos_account_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    offer_type = var.cosmos_offer_type
    kind = var.cosmos_kind
    mongo_server_version = var.mongo_server_version
    automatic_failover_enabled = var.cosmos_enable_automatic_failover
    consistency_policy {
        consistency_level = var.cosmos_consistency_level
    }
  capacity {
    total_throughput_limit = "-1"
  }
    geo_location {
        location = var.resource_location
        failover_priority = 0
    }
    capabilities {
        name = "EnableMongo"
        
    }
  
    is_virtual_network_filter_enabled = true
    
    
  public_network_access_enabled = false
  tags = var.resource_tags

}
resource "azurerm_private_endpoint" "cosmosdb_private_endpoint" {
    name = "${var.cosmos_account_name}-pe"
    location = var.resource_location
    resource_group_name = var.resource_group_name
    subnet_id = var.pe_vnet_subnet_id
    private_service_connection {
        name = "${var.cosmos_account_name}-psc"
        private_connection_resource_id = azurerm_cosmosdb_account.cosmos_account.id
        is_manual_connection = false
        subresource_names = ["MongoDB"]
        
    }
    tags = var.resource_tags
    depends_on = [ azurerm_cosmosdb_account.cosmos_account ]
  
}