variable "resource_group_name" { type = string }
variable "name" { type = string }
variable "subnet_id" { type = string }
variable "target_resource_id" { type = string }
variable "subresource_names" { type = list(string) }
variable "dns_zone_names" { type = list(string) }
variable "dns_zone_resource_group_name" { type = string }

resource "azurerm_private_endpoint" "this" {
  name                          = var.name
  location                      = "eastus2"
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "${var.name}-nic"
  tags                          = {}

  private_service_connection {
    name                           = var.name
    private_connection_resource_id = var.target_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.dns_zone_names) == 0 ? [] : [1]
    content {
      name                 = "default"
      private_dns_zone_ids = [for zone in var.dns_zone_names : data.azurerm_private_dns_zone.this[zone].id]
    }
  }
}

data "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.dns_zone_names)
  name                = each.value
  resource_group_name = var.dns_zone_resource_group_name
}

output "id" { value = azurerm_private_endpoint.this.id }
