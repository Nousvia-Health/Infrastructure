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
  # AzureRM uses Shared Key for Azure Files data-plane operations.
  shared_access_key_enabled = true

  azure_files_authentication {
    directory_type                 = "AADKERB"
    default_share_level_permission = var.default_share_level_permission
  }

  tags = var.tags
}

resource "azurerm_storage_share" "this" {
  for_each           = var.file_shares
  name               = each.value.name
  storage_account_id = azurerm_storage_account.this.id
  quota              = each.value.quota_gb
}

locals {
  file_share_role_assignments = merge([
    for share_key, share in var.file_shares : {
      for assignment_key, assignment in share.role_assignments :
      "${share_key}.${assignment_key}" => merge(assignment, { share_key = share_key })
    }
  ]...)
}

resource "azurerm_role_assignment" "file_share" {
  for_each = local.file_share_role_assignments

  scope                = azurerm_storage_share.this[each.value.share_key].rbac_scope_id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  principal_type       = each.value.principal_type
}
