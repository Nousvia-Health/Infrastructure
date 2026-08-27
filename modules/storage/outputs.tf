output "id" {
  description = "Storage account resource ID."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "file_share_url" {
  description = "Compatibility endpoint for the first share by sorted logical key; use file_share_urls for all shares."
  value = try(
    "https://${azurerm_storage_account.this.name}.file.core.windows.net/${azurerm_storage_share.this[sort(keys(azurerm_storage_share.this))[0]].name}",
    null
  )
}

output "file_share_urls" {
  description = "Azure Files share endpoints keyed by logical share name."
  value = {
    for key, share in azurerm_storage_share.this :
    key => "https://${azurerm_storage_account.this.name}.file.core.windows.net/${share.name}"
  }
}
