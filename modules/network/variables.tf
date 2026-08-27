variable "location" {
  description = "Azure region for network resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the network resources."
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual network address space."
  type        = list(string)
}

variable "subnet_name" {
  description = "Private endpoint subnet name."
  type        = string
}

variable "private_endpoint_subnet_cidr" {
  description = "CIDR for the private endpoint subnet."
  type        = string
}

variable "nsg_name" {
  description = "Network security group name."
  type        = string
}

variable "private_dns_zone_name" {
  description = "Shared private DNS zone for Azure Files endpoints on this network."
  type        = string
}

variable "tags" {
  description = "Network resource tags."
  type        = map(string)
}
