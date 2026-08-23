variable "vnet_name" {
    type = string
    description = "Name of the virtual network"
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "resource_location" {
    type = string
    description = "Azure region for the resource group"
}

variable "address_space" {
    type = list(string)
    description = "Address space for the virtual network"
}

variable "resource_tags" {
    type = map(string)
    description = "Tags for the resource group"
}

