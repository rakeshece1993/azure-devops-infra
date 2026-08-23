variable "nic_name" {
    type = string
    description = "Prefix for the resource name"
  
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "resource_location" {
    type = string
    description = "Azure region for the resource group"
}

variable "ip_config_name" {
    type = string
    description = "Name of the IP configuration"
}

variable "subnet_id" {
    type = string
    description = "Subnet ID for the network interface"
}

variable "resource_tags" {
    type = map(string)
    description = "Tags for the network interface"
}