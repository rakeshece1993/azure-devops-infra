variable "redis_cache_name" {
    type = string
    description = "Name of the redis cache"
  
}

variable "resource_location" {
    type = string
    description = "Location of the redis cache"
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "redis_cache_capacity" {
    type = number
    description = "Capacity of the redis cache"
}

variable "redis_cache_family" {
    type = string
    description = "Family of the redis cache"
}

variable "redis_cache_sku_name" {
    type = string
    description = "SKU name of the redis cache"
}

variable "redis_cache_non_ssl_port_enabled" {
    type = bool
    description = "Enable non SSL port for the redis cache"
}
variable "pe_vnet_subnet_id" {
    type = string
    description = "Subnet id for the private endpoint"
  
}

variable "resource_tags" {
    type = map(string)
    description = "Tags for the resource group"
}


