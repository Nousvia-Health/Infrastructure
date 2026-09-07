variable "resource_group_name" { type = string }
variable "vnet_name" { type = string }
variable "address_space" { type = list(string) }
variable "private_endpoint_subnet" { type = object({ name = string, address_prefixes = list(string) }) }
variable "integration_subnet" { type = object({ name = string, address_prefixes = list(string) }) }
variable "dbx_host_subnet_name" { type = string }
variable "dbx_container_subnet_name" { type = string }
variable "nsg_name" { type = string }
variable "nat_gateway_name" { type = string }
variable "nat_gateway_subnet_name" {
  type    = string
  default = null
}
variable "public_ip_name" { type = string }
variable "public_ip_tags" { type = map(string) }
variable "common_tags" { type = map(string) }
variable "nsg_ownership" {
  type    = string
  default = "platform_managed"
}
variable "private_dns_zone_link_names" { type = map(string) }

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = "eastus2"
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  encryption {
    enforcement = "AllowUnencrypted"
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = var.private_endpoint_subnet.name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = var.private_endpoint_subnet.address_prefixes
  default_outbound_access_enabled   = false
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "integration" {
  name                              = var.integration_subnet.name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = var.integration_subnet.address_prefixes
  default_outbound_access_enabled   = false
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_public_ip" "nat" {
  name                 = var.public_ip_name
  location             = "eastus2"
  resource_group_name  = var.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
  ddos_protection_mode = "Disabled"
  tags                 = merge(var.common_tags, var.public_ip_tags)
}

resource "azurerm_nat_gateway" "this" {
  name                    = var.nat_gateway_name
  location                = "eastus2"
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  zones                   = ["1"]
  tags                    = var.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = "eastus2"
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  lifecycle {
    ignore_changes = [security_rule, tags]
    precondition {
      condition     = contains(["platform_managed", "terraform_managed"], var.nsg_ownership)
      error_message = "nsg_ownership must be platform_managed or terraform_managed."
    }
  }
}

data "azurerm_subnet" "nat" {
  count                = var.nat_gateway_subnet_name == null ? 0 : 1
  name                 = var.nat_gateway_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  count          = var.nat_gateway_subnet_name == null ? 0 : 1
  subnet_id      = data.azurerm_subnet.nat[0].id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(keys(var.private_dns_zone_link_names))
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.private_dns_zone_link_names
  name                  = each.value
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
  tags                  = var.common_tags
}

data "azurerm_subnet" "dbx_host" {
  name                 = var.dbx_host_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "dbx_container" {
  name                 = var.dbx_container_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

output "vnet_id" { value = azurerm_virtual_network.this.id }
output "private_endpoint_subnet_id" { value = azurerm_subnet.private_endpoints.id }
output "dbx_host_subnet_id" { value = data.azurerm_subnet.dbx_host.id }
output "dbx_container_subnet_id" { value = data.azurerm_subnet.dbx_container.id }
