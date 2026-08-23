variable "nsg_name" {
  type = string
  description = "Name of the nsg"
}

variable "resource_group_name" {
  type = string
  description = "Name of the resource group"
}
variable "resource_location" {
  type = string
  description = "nsg location"
}
variable "resource_tags" {
  type = map(string)
  description = "Tags for the nsg"
}