variable "name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

output "id" { value = azurerm_resource_group.this.id }
output "name" { value = azurerm_resource_group.this.name }
