variable "cosmos_account_name" {
    type = string
    description = "Name of the cosmos account"
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "resource_location" {
    type = string
    description = "Azure region for the resource group"
}

variable "cosmos_offer_type" {
    type = string
    description = "Offer type for the cosmos account"
}

variable "cosmos_kind" {
    type = string
    description = "Kind of the cosmos account"
}

variable "cosmos_consistency_level" {
    type = string
    description = "Consistency level for the cosmos account"
}

variable "mongo_server_version" {
    type = string
    description = "Mongo server version for the cosmos account"
}

variable "cosmos_enable_automatic_failover" {
    type = bool
    description = "Enable automatic failover for the cosmos account"
}

variable "pe_vnet_subnet_id" {
    type = string
    description = "Subnet id for the private endpoint"
}

variable "resource_tags" {
    type = map(string)
    description = "Tags for the resource group"
}