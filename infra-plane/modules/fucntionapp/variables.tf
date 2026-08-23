variable "function_app_name" {
    type = string
    description = "Name of the function app"
}


variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "resource_location" {
    type = string
    description = "Azure region for the resource group"
}
variable "app_service_plan_id" {
    type = string
    description = "App service plan id for the function app"
}
variable "storage_account_name" {
    type = string
    description = "Storage account name for the function app"
}
variable "storage_account_access_key" {
    type = string
    description = "Storage account access key for the function app"
}
variable "resource_tags" {
    type = map(string)
    description = "Tags for the resource group"
}
variable "java_version" {
    type = string
    description = "Java version for the function app"
}
