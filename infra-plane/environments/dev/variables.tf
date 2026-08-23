variable "environment_name" {
  type        = string
  description = "Environment name"
  
}

variable "platform_name" {
  type        = string
  description = "Platform name"
}

variable "program_name" {
  type        = string
  description = "Program name"
}

variable "module_name" {
  type        = string
  description = "Module name"
}
variable "resource_location" {
  type = string
  description = "Azure resource region"
}
variable "custom_tags" {
  type = map(string)
  description = "Custom tags for the resource group"
  default = {}
}


#virtual network info
variable "spoke_cidr_prefix" {
  type = string
  description = "CIDR prefix for the spoke vnet"

}
