output "firewall_policy_id" {
  value       = azurerm_firewall_policy.fw_policy.id
  description = "The ID of the Firewall Policy"
}

output "firewall_policy_name" {
  value       = azurerm_firewall_policy.fw_policy.name
  description = "The name of the Firewall Policy"
}

output "app_ip_group_id" {
  value       = azurerm_ip_group.app.id
  description = "The ID of the Application IP Group"
}

output "mgmt_ip_group_id" {
  value       = azurerm_ip_group.mgmt.id
  description = "The ID of the Management IP Group"
}

output "rule_collection_group_id" {
  value       = azurerm_firewall_policy_rule_collection_group.rcg_prod.id
  description = "The ID of the Rule Collection Group"
}

