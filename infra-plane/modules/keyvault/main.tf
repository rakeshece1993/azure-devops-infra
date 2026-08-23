
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  sku_name            = var.key_vault_sku
  tags                = var.resource_tags
  tenant_id           = data.azurerm_client_config.current.tenant_id
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
  }

}



