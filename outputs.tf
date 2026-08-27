output "resource_group_id" {
  description = "Compatibility resource group ID for the deployment key; use resource_group_ids for map mode."
  value       = try(module.resource_group["deployment"].id, null)
}

output "storage_account_id" {
  description = "Compatibility storage account ID for the storage key; use storage_account_ids for map mode."
  value       = try(module.storage["storage"].id, null)
}

output "file_share_url" {
  description = "Compatibility endpoint for the first share of the storage key; use file_share_urls for all shares."
  value       = try(module.storage["storage"].file_share_url, null)
}

output "private_endpoint_ip" {
  description = "Compatibility private IP for the storage endpoint key; use private_endpoint_ips for map mode."
  value       = try(module.private_endpoint["storage"].private_ip_address, null)
}

output "private_dns_zone_id" {
  description = "Compatibility DNS zone ID for the storage endpoint key; use private_dns_zone_ids for map mode."
  value       = try(module.private_endpoint["storage"].private_dns_zone_id, null)
}

output "resource_group_ids" {
  description = "Resource group IDs keyed by logical name."
  value       = { for key, resource_group in module.resource_group : key => resource_group.id }
}

output "storage_account_ids" {
  description = "Storage account IDs keyed by logical name."
  value       = { for key, storage in module.storage : key => storage.id }
}

output "network_ids" {
  description = "Virtual network resource IDs keyed by logical network name."
  value       = { for key, network in module.network : key => network.vnet_id }
}

output "private_endpoint_subnet_ids" {
  description = "Private endpoint subnet IDs keyed by logical network name."
  value       = { for key, network in module.network : key => network.private_endpoint_subnet_id }
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by logical private endpoint name."
  value       = { for key, endpoint in module.private_endpoint : key => endpoint.private_dns_zone_id }
}

output "file_share_urls" {
  description = "Azure Files share endpoints keyed by storage account and share."
  value = {
    for storage_key, storage in module.storage : storage_key => storage.file_share_urls
  }

}

output "private_endpoint_ips" {
  description = "Private endpoint IPs keyed by logical endpoint name."
  value       = { for key, endpoint in module.private_endpoint : key => endpoint.private_ip_address }
}
