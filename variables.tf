variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra tenant ID."
  default     = null
}

variable "resource_groups" {
  description = "Existing resource groups to adopt."
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  default = {}
}

variable "network" {
  description = "Existing shared VNet and network resources."
  type = object({
    resource_group_name         = string
    vnet_name                   = string
    address_space               = list(string)
    private_endpoint_subnet     = object({ name = string, address_prefixes = list(string) })
    integration_subnet          = object({ name = string, address_prefixes = list(string) })
    dbx_host_subnet_name        = string
    dbx_container_subnet_name   = string
    nsg_name                    = string
    nat_gateway_name            = string
    nat_gateway_subnet_name     = optional(string)
    public_ip_name              = string
    public_ip_tags              = map(string)
    nsg_ownership               = optional(string, "platform_managed")
    private_dns_zone_link_names = map(string)
  })
  default = null
}

variable "common_tags" {
  description = "Tags applied to all taggable Terraform-managed resources."
  type        = map(string)
  default     = {}
}

variable "storage" {
  description = "Existing ADLS Gen2 storage account."
  type = object({
    resource_group_name           = string
    name                          = string
    account_replication_type      = string
    public_network_access_enabled = optional(bool, true)
    shared_access_key_enabled     = optional(bool, true)
  })
  default = null
}

variable "access_connector" {
  type = object({
    resource_group_name = string
    name                = string
    tags                = optional(map(string), {})
  })
  default = null
}

variable "key_vault" {
  type = object({
    resource_group_name           = string
    name                          = string
    public_network_access_enabled = optional(bool, true)
    purge_protection_enabled      = optional(bool, true)
    tags                          = optional(map(string), {})
  })
  default = null
}

variable "monitoring" {
  type = object({
    resource_group_name        = string
    name                       = string
    retention_in_days          = number
    internet_ingestion_enabled = optional(bool, true)
    internet_query_enabled     = optional(bool, true)
    diagnostic_settings = optional(map(object({
      target_resource_id = string
      log_categories     = optional(list(string), [])
      metric_categories  = optional(list(string), [])
    })), {})
  })
  default = null
}

variable "databricks" {
  description = "Existing VNet-injected Databricks workspace."
  type = object({
    resource_group_name           = string
    name                          = string
    managed_resource_group_name   = string
    sku                           = string
    custom_public_subnet_name     = string
    custom_private_subnet_name    = string
    storage_account_sku_name      = string
    tags                          = map(string)
    public_network_access_enabled = optional(bool, true)
    generated_resource_ownership  = optional(string, "databricks")
  })
  default = null
}

variable "private_endpoints" {
  description = "Existing private endpoints and their target resource groups."
  type = map(object({
    resource_group_name          = string
    name                         = string
    subnet_id                    = string
    target_resource_id           = string
    subresource_names            = list(string)
    dns_zone_names               = list(string)
    dns_zone_resource_group_name = string
  }))
  default = {}
}

variable "network_watcher" {
  type    = object({ resource_group_name = string, name = string, location = string })
  default = null
}
