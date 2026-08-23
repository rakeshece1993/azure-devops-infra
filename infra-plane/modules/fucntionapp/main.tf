

resource "azurerm_linux_function_app" "function_app" {
    name = var.function_app_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    service_plan_id = var.app_service_plan_id
    storage_account_name = var.storage_account_name
    storage_account_access_key = var.storage_account_access_key
    tags = var.resource_tags
    site_config {
    application_stack {
      java_version = var.java_version
    }
  }
}