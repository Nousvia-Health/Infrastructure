resource "azurerm_storage_account" "this" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = var.replication_type
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  tags = var.tags
}

resource "azurerm_storage_share" "this" {
  for_each           = var.file_shares
  name               = each.value.name
  storage_account_id = azurerm_storage_account.this.id
  quota              = each.value.quota_gb
}
