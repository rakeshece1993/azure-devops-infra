variable "route_table_name" {
  type        = string
  description = "Name of the route table"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "resource_location" {
  type        = string
  description = "Azure region for the route table"
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags to apply to the route table"
  default     = {}
}

variable "firewall_private_ip" {
  type        = string
  description = "Private IP address of the Azure Firewall"
}

variable "disable_bgp_route_propagation" {
  type        = bool
  description = "Disable BGP route propagation (set to true for spoke VNets)"
  default     = true
}

variable "spoke_address_prefixes" {
  type        = map(string)
  description = "Map of spoke name to address prefix for inter-spoke routing"
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate with this route table"
  default     = []
}

