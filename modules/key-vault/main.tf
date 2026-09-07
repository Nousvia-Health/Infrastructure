variable "resource_group_name" { type = string }
variable "name" { type = string }
variable "public_network_access_enabled" { type = bool }
variable "purge_protection_enabled" { type = bool }

resource "azurerm_key_vault" "this" {
  name                            = var.name
  location                        = "eastus2"
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  rbac_authorization_enabled      = true
  soft_delete_retention_days      = 90
  purge_protection_enabled        = var.purge_protection_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
}

data "azurerm_client_config" "current" {}

output "id" { value = azurerm_key_vault.this.id }
