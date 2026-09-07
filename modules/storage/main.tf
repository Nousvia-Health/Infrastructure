variable "resource_group_name" { type = string }
variable "name" { type = string }
variable "account_replication_type" { type = string }
variable "public_network_access_enabled" { type = bool }
variable "shared_access_key_enabled" { type = bool }

resource "azurerm_storage_account" "this" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = "eastus2"
  account_tier                      = "Standard"
  account_replication_type          = var.account_replication_type
  account_kind                      = "StorageV2"
  is_hns_enabled                    = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  default_to_oauth_authentication   = true
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  infrastructure_encryption_enabled = false
}

output "id" { value = azurerm_storage_account.this.id }
