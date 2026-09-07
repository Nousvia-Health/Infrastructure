variable "resource_group_name" { type = string }
variable "name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_network_watcher" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
