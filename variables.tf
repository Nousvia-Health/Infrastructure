variable "location" {
  description = "Azure region for the resources."
  type        = string
  default     = "eastus"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,50}$", trimspace(var.location)))
    error_message = "location must be a valid Azure region name using 2-50 lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group that owns the deployment."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.resource_group_name == null || (can(regex("^[^<>%&\\\\?/]{1,90}$", try(trimspace(var.resource_group_name), ""))) && try(trimspace(var.resource_group_name), "") == var.resource_group_name)
    error_message = "resource_group_name must be non-empty and at most 90 characters when specified."
  }
}

variable "storage_account_name" {
  description = "Globally unique, lowercase Azure Storage Account name."
  type        = string
  default     = "azurefilesdev"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 lowercase letters or numbers."
  }
}

variable "file_share_name" {
  description = "Name of the Azure Files share."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.file_share_name == null || (can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", try(trimspace(var.file_share_name), ""))) && try(trimspace(var.file_share_name), "") == var.file_share_name)
    error_message = "file_share_name must be 3-63 characters using lowercase letters, numbers, or hyphens when specified."
  }
}

variable "file_share_quota_gb" {
  description = "Maximum size of the Azure Files share in GiB."
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.file_share_quota_gb == null ? true : (var.file_share_quota_gb >= 1 && var.file_share_quota_gb <= 102400)
    error_message = "file_share_quota_gb must be between 1 and 102400 GiB when specified."
  }
}

variable "azure_files_default_share_level_permission" {
  description = "Default Azure Files SMB permission for authenticated identities. Keep None when using explicit share-level role assignments."
  type        = string
  default     = "None"

  validation {
    condition = contains([
      "None",
      "StorageFileDataSmbShareReader",
      "StorageFileDataSmbShareContributor",
      "StorageFileDataSmbShareElevatedContributor"
    ], var.azure_files_default_share_level_permission)
    error_message = "azure_files_default_share_level_permission must be None or a supported Azure Files SMB share permission."
  }
}

variable "file_share_role_assignments" {
  description = "Share-level Azure RBAC assignments used by the legacy singular file share."
  type = map(object({
    principal_id         = string
    role_definition_name = optional(string, "Storage File Data SMB Share Contributor")
    principal_type       = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for assignment in values(var.file_share_role_assignments) :
      can(regex("^[0-9a-fA-F-]{36}$", assignment.principal_id)) &&
      contains([
        "Storage File Data SMB Share Reader",
        "Storage File Data SMB Share Contributor",
        "Storage File Data SMB Share Elevated Contributor",
        "Storage File Data SMB Admin"
      ], assignment.role_definition_name) &&
      (assignment.principal_type == null || contains(["User", "Group", "ServicePrincipal"], assignment.principal_type))
    ])
    error_message = "Each file share role assignment must use a valid principal object ID, supported Azure Files SMB role, and optional User, Group, or ServicePrincipal type."
  }
}

variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = list(string)
  default     = ["10.20.0.0/16"]

  validation {
    condition     = length(var.vnet_address_space) > 0 && length(distinct(var.vnet_address_space)) == length(var.vnet_address_space) && alltrue([for cidr in var.vnet_address_space : can(cidrhost(cidr, 0))])
    error_message = "vnet_address_space must contain at least one valid CIDR."
  }
}

variable "private_endpoint_subnet_cidr" {
  description = "CIDR for the dedicated private endpoint subnet."
  type        = string
  default     = "10.20.1.0/24"

  validation {
    condition     = can(cidrhost(var.private_endpoint_subnet_cidr, 0))
    error_message = "private_endpoint_subnet_cidr must be a valid CIDR."
  }
}

variable "storage_account_replication_type" {
  description = "Storage replication type. Select ZRS, GRS, or GZRS after RTO/RPO review."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS"], var.storage_account_replication_type)
    error_message = "storage_account_replication_type must be LRS, ZRS, GRS, or GZRS."
  }
}

variable "resource_groups" {
  description = "Resource groups keyed by logical name. When null, the legacy singular inputs create deployment."
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
  default  = null
  nullable = true

  validation {
    condition = var.resource_groups == null ? true : alltrue([
      for resource_group in values(var.resource_groups) :
      can(regex("^[^<>%&\\\\?/]{1,90}$", resource_group.name)) && trimspace(resource_group.name) == resource_group.name &&
      can(regex("^[a-z0-9-]{2,50}$", trimspace(resource_group.location))) &&
      alltrue([for value in values(resource_group.tags) : trimspace(value) != ""])
    ]) && length(distinct([for resource_group in values(var.resource_groups) : resource_group.name])) == length(var.resource_groups)
    error_message = "Each resource group must have a unique valid name, Azure region, and non-empty tag values."
  }
}

variable "networks" {
  description = "Reusable networks keyed by logical name."
  type = map(object({
    resource_group_key           = string
    vnet_name                    = string
    vnet_address_space           = list(string)
    private_endpoint_subnet_name = string
    private_endpoint_subnet_cidr = string
    nsg_name                     = string
    private_dns_zone_name        = optional(string, "privatelink.file.core.windows.net")
    location                     = optional(string)
    tags                         = optional(map(string), {})
  }))
  default  = null
  nullable = true

  validation {
    condition = var.networks == null ? true : (alltrue([
      for network in values(var.networks) :
      trimspace(network.resource_group_key) != "" && can(regex("^[A-Za-z0-9][A-Za-z0-9._-]{1,63}$", network.vnet_name)) &&
      length(network.vnet_address_space) > 0 &&
      length(distinct(network.vnet_address_space)) == length(network.vnet_address_space) &&
      alltrue([for cidr in network.vnet_address_space : can(cidrhost(cidr, 0))]) &&
      can(cidrhost(network.private_endpoint_subnet_cidr, 0)) &&
      can(regex("^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$", network.private_endpoint_subnet_name)) &&
      can(regex("^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$", network.nsg_name)) &&
      can(regex("^[a-z0-9.-]{1,63}$", network.private_dns_zone_name)) &&
      alltrue([for value in values(network.tags) : trimspace(value) != ""])
      ]) && length(distinct([for network in values(var.networks) : network.vnet_name])) == length(var.networks) &&
      length(distinct([for network in values(var.networks) : network.private_endpoint_subnet_name])) == length(var.networks) &&
    length(distinct([for network in values(var.networks) : network.nsg_name])) == length(var.networks))
    error_message = "Each network must have valid Azure names, unique valid CIDRs, a resource group key, and non-empty tag values."
  }
}

variable "storage_accounts" {
  description = "Storage accounts keyed by logical name, each with one or more Azure Files shares."
  type = map(object({
    resource_group_key             = string
    name                           = string
    replication_type               = string
    location                       = optional(string)
    tags                           = optional(map(string), {})
    default_share_level_permission = optional(string, "None")
    file_shares = map(object({
      name     = string
      quota_gb = number
      role_assignments = optional(map(object({
        principal_id         = string
        role_definition_name = optional(string, "Storage File Data SMB Share Contributor")
        principal_type       = optional(string)
      })), {})
    }))
  }))
  default  = null
  nullable = true

  validation {
    condition = var.storage_accounts == null ? true : alltrue([
      for account in values(var.storage_accounts) :
      can(regex("^[a-z0-9]{3,24}$", account.name)) && trimspace(account.resource_group_key) != "" &&
      contains(["LRS", "ZRS", "GRS", "GZRS"], account.replication_type) &&
      contains([
        "None",
        "StorageFileDataSmbShareReader",
        "StorageFileDataSmbShareContributor",
        "StorageFileDataSmbShareElevatedContributor"
      ], account.default_share_level_permission) &&
      length(account.file_shares) > 0 &&
      alltrue([
        for share in values(account.file_shares) :
        can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", share.name)) && trimspace(share.name) == share.name && floor(share.quota_gb) == share.quota_gb && share.quota_gb >= 1 && share.quota_gb <= 102400 &&
        alltrue([
          for assignment in values(share.role_assignments) :
          can(regex("^[0-9a-fA-F-]{36}$", assignment.principal_id)) &&
          contains([
            "Storage File Data SMB Share Reader",
            "Storage File Data SMB Share Contributor",
            "Storage File Data SMB Share Elevated Contributor",
            "Storage File Data SMB Admin"
          ], assignment.role_definition_name) &&
          (assignment.principal_type == null || contains(["User", "Group", "ServicePrincipal"], assignment.principal_type))
        ])
      ])
      && length(distinct([for share in values(account.file_shares) : share.name])) == length(account.file_shares)
      && alltrue([for value in values(account.tags) : trimspace(value) != ""])
    ]) && length(distinct([for account in values(var.storage_accounts) : account.name])) == length(var.storage_accounts)
    error_message = "Each storage account must have a unique valid Azure name, resource group key, replication type, non-empty tags, and file shares with quotas from 1 to 102400 GiB."
  }
}

variable "private_endpoints" {
  description = "Private endpoints keyed by logical name and assigned to a network and storage account."
  type = map(object({
    resource_group_key  = string
    network_key         = string
    storage_account_key = string
    name                = string
    location            = optional(string)
    tags                = optional(map(string), {})
  }))
  default  = null
  nullable = true

  validation {
    condition = var.private_endpoints == null ? true : alltrue([
      for endpoint in values(var.private_endpoints) :
      trimspace(endpoint.resource_group_key) != "" && trimspace(endpoint.network_key) != "" &&
      trimspace(endpoint.storage_account_key) != "" && can(regex("^[A-Za-z0-9][A-Za-z0-9._-]{1,79}$", endpoint.name)) &&
      alltrue([for value in values(endpoint.tags) : trimspace(value) != ""])
    ]) && length(distinct([for endpoint in values(var.private_endpoints) : endpoint.name])) == length(var.private_endpoints)
    error_message = "Each private endpoint must have valid names, non-empty resource group/network/storage keys, and non-empty tag values."
  }
}

variable "tags" {
  description = "Required ownership and governance tags."
  type        = map(string)
  default = {
    environment         = "dev"
    workload            = "azure-files"
    owner               = "unassigned"
    cost_center         = "unassigned"
    data_classification = "internal"
    managed_by          = "terraform"
  }

  validation {
    condition = alltrue([
      for key in ["environment", "workload", "owner", "cost_center", "data_classification", "managed_by"] :
      contains(keys(var.tags), key) && trimspace(var.tags[key]) != ""
    ])
    error_message = "tags must contain non-empty environment, workload, owner, cost_center, data_classification, and managed_by values."
  }
}
