variable "subnet_name" {
    type = string
    description = "Name of the subnet"
  
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "virtual_network_name" {
    type = string
    description = "Name of the virtual network"
}

variable "subnet_prefix" {
    type = string
    description = "CIDR prefix for the subnet"
}

