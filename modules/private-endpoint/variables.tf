variable "location" {
  description = "Azure region for the private endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the private endpoint resources."
  type        = string
}

variable "private_endpoint_name" {
  description = "Private endpoint name."
  type        = string
}

variable "subnet_id" {
  description = "Subnet resource ID for the private endpoint."
  type        = string
}

variable "storage_account_id" {
  description = "Storage account resource ID targeted by the private endpoint."
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name used in the connection name."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Shared private DNS zone resource ID for Azure Files."
  type        = string
}

variable "tags" {
  description = "Private endpoint resource tags."
  type        = map(string)
}
