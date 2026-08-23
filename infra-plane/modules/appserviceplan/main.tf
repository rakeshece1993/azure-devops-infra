resource "azurerm_service_plan" "app_service_plan" {
    name = var.app_service_plan_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    os_type = var.os_type
    sku_name = var.sku_name
    tags = var.resource_tags
}
