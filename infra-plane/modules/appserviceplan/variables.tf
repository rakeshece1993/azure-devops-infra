variable "app_service_plan_name" {
    type = string
    description = "App service plan name for the function app"
}
variable "os_type" {
    type = string
    description = "OS type for the app service plan"
}
variable "sku_name" {
    type = string
    description = "SKU name for the app service plan"
}
variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}
variable "resource_location" {
    type = string
    description = "Azure region for the resource group"
}
variable "resource_tags" {
    type = map(string)
    description = "Tags for the resource group"
}