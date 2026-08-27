output "private_ip_address" {
  description = "Private IP assigned to the Azure Files private endpoint."
  value       = azurerm_private_endpoint.files.private_service_connection[0].private_ip_address
}

output "private_dns_zone_id" {
  description = "Private DNS zone resource ID."
  value       = var.private_dns_zone_id
}
