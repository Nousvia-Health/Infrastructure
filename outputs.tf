output "resource_group_ids" {
  value = { for key, group in module.resource_groups : key => group.id }
}

output "vnet_id" {
  value = try(module.network[0].vnet_id, null)
}

output "private_endpoint_ids" {
  value = { for key, endpoint in module.private_endpoints : key => endpoint.id }
}

output "databricks_workspace_url" {
  value     = try(module.databricks[0].workspace_url, null)
  sensitive = true
}
