
module "spoke_resources_rg" {

    source = "../../modules/resourceGroup"
    resource_group_name = "${local.resource_name_prefix}-rg"
    resource_location = local.primary_resource_location
    resource_tags = merge(local.common_tags, var.custom_tags)
}

#Deploying virtual network spoke
module "spoke_vnet" {
    source = "../../modules/spokenet"
    vnet_name = "${local.module_spoke_vnet_name}"
    resource_group_name = module.spoke_resources_rg.resource_group_name_output
    resource_location = local.primary_resource_location
    address_space = [var.spoke_cidr_prefix]
    resource_tags = merge(local.common_tags, var.custom_tags)
}

#Deploying subnets
module "vnet_subnet" {
    source = "../../modules/subnet"
    for_each = local.subnet_name_cidr_prefix
    subnet_name = each.key
    resource_group_name = module.spoke_resources_rg.resource_group_name_output
    virtual_network_name = module.spoke_vnet.spoke_virtual_netowrk_name_output
    subnet_prefix = each.value
    depends_on = [ module.spoke_vnet ]
}

#Deploying NIC

module "nic_card" {
    source = "../../modules/nic"
    nic_name = local.nic_name
    resource_group_name = module.spoke_resources_rg.resource_group_name_output
    resource_location = local.primary_resource_location
    ip_config_name = "adaptor-config-00"
    subnet_id = module.vnet_subnet[local.common-subnet].subnet_id_output
    resource_tags = merge(local.common_tags, var.custom_tags)
    depends_on = [ module.vnet_subnet ]
}

# Deploying NSG 
module "netowrk_security_group" {
    source = "../../modules/nsg"
    nsg_name = local.nsg_name
    resource_group_name = module.spoke_resources_rg.resource_group_name_output
    resource_location = local.primary_resource_location
    resource_tags = merge(local.common_tags, var.custom_tags)
    depends_on = [ module.spoke_resources_rg ]
}
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
    network_interface_id = module.nic_card.network_interface_id_output
    network_security_group_id = module.netowrk_security_group.network_security_group_id_output
    depends_on = [ module.netowrk_security_group, module.nic_card  ]
}

# # Deploying VM
# module "linux_vm" {
#     source = "../../modules/vm/linux"
#     virtual_machine_name = local.linux_vm_name
#     resource_group_name = module.spoke_resources_rg.resource_group_name_output
#     resource_location = local.primary_resource_location
#     network_interface_id = module.nic_card.network_interface_id_output
#     vm_size = local.linux_vm_size
#     admin_username = local.linux_admin_username
#     resource_tags = merge(local.common_tags, var.custom_tags)
#     key_vault_id = module.key_vault.key_vault_id_output
#     depends_on = [ azurerm_network_interface_security_group_association.nic_nsg_association ]
#     os_image_reference = local.os_image_reference
    
# }

# # Deploying Key vault
# module "key_vault" {
#     source = "../../modules/keyvault"
#     key_vault_name = "${local.resource_name_prefix}-kv"
#     resource_group_name = module.spoke_resources_rg.resource_group_name_output
#     resource_location = local.primary_resource_location
#     key_vault_sku = "standard"
#     resource_tags = merge(local.common_tags, var.custom_tags)
#     depends_on = [ module.spoke_resources_rg ]
    
# }


#Deploying a Kubertnetes cluster
# module "aks_cluster" {
#     source = "../../modules/aks"
#     aks_cluster_name = "${local.resource_name_prefix}-aks"
#     prefix = "${local.resource_name_prefix}-aks"
#     resource_location = module.spoke_resources_rg.resource_group_location_output
#     resource_group_name = module.spoke_resources_rg.resource_group_name_output
#     auto_scaling_enabled = true
#     user_node_pool_details = local.user_node_pool_details
#     vnet_subnet = {
#         id = module.vnet_subnet[local.aks-subnet].subnet_id_output
#     }

#     resource_tags = merge(local.common_tags, var.custom_tags)
#     depends_on = [ module.vnet_subnet ]
# }

#Deploying Cosmos account
# module "cosmos_account" {
#     source = "../../modules/cosmos"
#     cosmos_account_name = "${local.resource_name_prefix}-cosmos"
#     resource_group_name = module.spoke_resources_rg.resource_group_name_output
#     resource_location = local.primary_resource_location
#     cosmos_offer_type = "Standard"
#     cosmos_kind = "MongoDB"
#     mongo_server_version = "7.0"
#     cosmos_consistency_level = "Session"
#     cosmos_enable_automatic_failover = false
#     resource_tags = merge(local.common_tags, var.custom_tags)
#     pe_vnet_subnet_id = module.vnet_subnet[local.aks-subnet].subnet_id_output
#     depends_on = [ module.vnet_subnet ]

# }

#Deploying Redis cache
module "redis_cache" {
    source = "../../modules/redis"
    redis_cache_name = "${local.resource_name_prefix}-redis"
    resource_location = local.primary_resource_location
    resource_group_name = module.spoke_resources_rg.resource_group_name_output
    redis_cache_capacity = 1
    redis_cache_family = "C"
    redis_cache_sku_name = "Standard"
    redis_cache_non_ssl_port_enabled = false
    resource_tags = merge(local.common_tags, var.custom_tags)
    pe_vnet_subnet_id = module.vnet_subnet[local.aks-subnet].subnet_id_output
    depends_on = [ module.spoke_resources_rg ]
}















# module "storage_account" {
# source = "../../modules/storageaccount"
# storage_account_name = "${var.environment_name}${var.platform_name}${var.program_name}${var.resource_location}sa"
# resource_group_name = module.spoke_resources_rg.resource_group_name
# resource_location = var.resource_location
# resource_tags = merge(local.common_tags, var.custom_tags)
# account_tier = "Standard"
# account_replication_type = "LRS"
# access_tier = "Hot"
# }

# module "app_service_plan" {
#   source                  = "../../modules/appserviceplan"
#   app_service_plan_name   = "${var.environment_name}-asp"
#   resource_group_name     = module.spoke_resources_rg.resource_group_name
#   resource_location       = var.resource_location
#   os_type                 = "Linux"
#   sku_name                = "B1"  # or,B1, "Y1", "P1v2", etc.
#   resource_tags           = local.common_tags
# }



# module "function_app" {
#   source = "../../modules/fucntionapp"
#   function_app_name = "${var.environment_name}-${var.platform_name}-${var.program_name}-${var.module_name}-${var.resource_location}-funcapp"
#   resource_group_name = module.spoke_resources_rg.resource_group_name
#   resource_location = var.resource_location
#   resource_tags = merge(local.common_tags, var.custom_tags)
#   depends_on = [ module.spoke_resources_rg, module.storage_account, module.app_service_plan ]
#   app_service_plan_id = module.app_service_plan.app_service_plan_id
#   storage_account_name = module.storage_account.storage_account_name
#   storage_account_access_key = module.storage_account.storage_account_primary_access_key
#   java_version = var.java_version
# }

# module "logic_app_workflow" {
#   source              = "../../modules/logicapp"
#   logic_app_name      = "${var.environment_name}-${var.platform_name}-${var.program_name}-${var.module_name}-${var.resource_location}-logicapp"
#   resource_group_name = module.spoke_resources_rg.resource_group_name
#   resource_location   = var.resource_location
#   resource_tags       = merge(local.common_tags, var.custom_tags)

# }
