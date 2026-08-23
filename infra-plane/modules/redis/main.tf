resource "azurerm_redis_cache" "azure_redis_cache" {
  name                 = var.redis_cache_name
  location             = var.resource_location
  resource_group_name  = var.resource_group_name
  capacity             = var.redis_cache_capacity
  family               = var.redis_cache_family
  sku_name             = var.redis_cache_sku_name
  non_ssl_port_enabled = var.redis_cache_non_ssl_port_enabled
  minimum_tls_version  = "1.2"
  public_network_access_enabled = false
  redis_version = "6"
  access_keys_authentication_enabled = true
  redis_configuration {

  }

  tags = var.resource_tags
}


resource "azurerm_private_endpoint" "redis_private_endpoint" {
    name = "${var.redis_cache_name}-pe"
    location = var.resource_location
    resource_group_name = var.resource_group_name
    subnet_id = var.pe_vnet_subnet_id
    private_service_connection {
        name = "${var.redis_cache_name}-psc"
        private_connection_resource_id = azurerm_redis_cache.azure_redis_cache.id
        is_manual_connection = false
        subresource_names = ["redisCache"]
        
    }
    tags = var.resource_tags
    depends_on = [ azurerm_redis_cache.azure_redis_cache ]
  
}


