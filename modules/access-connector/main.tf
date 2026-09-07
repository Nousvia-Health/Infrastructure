variable "resource_group_name" { type = string }
variable "name" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_databricks_access_connector" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = "eastus2"
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

output "id" { value = azurerm_databricks_access_connector.this.id }
output "principal_id" { value = azurerm_databricks_access_connector.this.identity[0].principal_id }
