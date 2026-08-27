output "vnet_id" {
  description = "Virtual network resource ID."
  value       = azurerm_virtual_network.this.id
}

output "private_endpoint_subnet_id" {
  description = "Private endpoint subnet resource ID."
  value       = azurerm_subnet.private_endpoints.id
}

output "private_dns_zone_id" {
  description = "Shared Azure Files private DNS zone resource ID."
  value       = azurerm_private_dns_zone.files.id
}
