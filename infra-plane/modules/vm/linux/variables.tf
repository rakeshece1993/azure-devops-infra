variable "virtual_machine_name" {
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

variable "network_interface_id" {
    type = string
    description = "Network interface id for the virtual machine"
}

variable "vm_size" {
    type = string
    description = "Size of the virtual machine"
}

variable "admin_username" {
    type = string
    description = "Admin username for the virtual machine"
}

variable "key_vault_id" {
    type = string
    description = "Key vault id for the virtual machine"
}
variable "os_image_reference" {
    type = map(string)
    description = "OS image reference for the virtual machine"
  
}



variable "resource_tags" {
    type = map(string)
    description = "Tags for the virtual machine"
}
