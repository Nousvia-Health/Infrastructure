variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "workspace_name" {
  type = string
}

variable "managed_resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "public_subnet_name" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "private_endpoint_subnet_name" {
  type = string
}

variable "private_endpoint_subnet_cidr" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_replication_type" {
  type = string
}

variable "tags" {
  type = map(string)
}