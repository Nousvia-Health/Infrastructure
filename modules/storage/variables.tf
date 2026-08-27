variable "location" {
  description = "Azure region for storage resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the storage resources."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique, lowercase Azure Storage Account name."
  type        = string
}

variable "file_shares" {
  description = "Azure Files shares keyed by logical name."
  type = map(object({
    name     = string
    quota_gb = number
  }))
}

variable "replication_type" {
  description = "Storage replication type."
  type        = string
}

variable "tags" {
  description = "Storage resource tags."
  type        = map(string)
}
