output "workspace_id" {
  value = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}