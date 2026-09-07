import {
  to = module.resource_groups["network"].azurerm_resource_group.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2"
}

import {
  to = module.resource_groups["data"].azurerm_resource_group.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-data-dev-eus2"
}

import {
  to = module.resource_groups["dbx"].azurerm_resource_group.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-dbx-dev-eus2"
}

import {
  to = module.resource_groups["monitor"].azurerm_resource_group.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-monitor-dev-eus2"
}

import {
  to = module.resource_groups["watcher"].azurerm_resource_group.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/NetworkWatcherRG"
}

import {
  to = module.network[0].azurerm_virtual_network.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/virtualNetworks/vnet-nousviahealth-dev-eus2"
}

import {
  to = module.network[0].azurerm_subnet.private_endpoints
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/virtualNetworks/vnet-nousviahealth-dev-eus2/subnets/snet-private-endpoints-dev-eus2"
}

import {
  to = module.network[0].azurerm_subnet.integration
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/virtualNetworks/vnet-nousviahealth-dev-eus2/subnets/snet-integration-dev-eus2"
}

import {
  to = module.network[0].azurerm_public_ip.nat
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/publicIPAddresses/pip-nousviahealth-nat-dev-eus2"
}

import {
  to = module.network[0].azurerm_nat_gateway.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/natGateways/rg-nousviahealth-network-dev-eus2"
}

import {
  to = module.network[0].azurerm_nat_gateway_public_ip_association.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/natGateways/rg-nousviahealth-network-dev-eus2|/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/publicIPAddresses/pip-nousviahealth-nat-dev-eus2"
}

import {
  to = module.network[0].azurerm_network_security_group.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/networkSecurityGroups/nsg-nousviahealth-dbx-dev-eus2"
}

import {
  for_each = var.network.private_dns_zone_link_names
  to       = module.network[0].azurerm_private_dns_zone.this[each.key]
  id       = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/privateDnsZones/${each.key}"
}

import {
  for_each = var.network.private_dns_zone_link_names
  to       = module.network[0].azurerm_private_dns_zone_virtual_network_link.this[each.key]
  id       = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/privateDnsZones/${each.key}/virtualNetworkLinks/${each.value}"
}

import {
  to = module.storage[0].azurerm_storage_account.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-data-dev-eus2/providers/Microsoft.Storage/storageAccounts/stnvhdbxdevuse2"
}

import {
  to = module.access_connector[0].azurerm_databricks_access_connector.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-data-dev-eus2/providers/Microsoft.Databricks/accessConnectors/ac-dbx-nousviahealth-dev-eus2"
}

import {
  to = module.key_vault[0].azurerm_key_vault.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-data-dev-eus2/providers/Microsoft.KeyVault/vaults/kv-nvh-dbx-dev-eus2"
}

import {
  to = module.monitoring[0].azurerm_log_analytics_workspace.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-monitor-dev-eus2/providers/Microsoft.OperationalInsights/workspaces/law-nousviahealth-dev-eus2"
}

import {
  to = module.databricks[0].azurerm_databricks_workspace.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-dbx-dev-eus2/providers/Microsoft.Databricks/workspaces/dbw-nousviahealth-dev-eus2"
}

import {
  to = module.network_watcher[0].azurerm_network_watcher.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_eastus2"
}

import {
  to = module.private_endpoints["storage_blob"].azurerm_private_endpoint.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-data-dev-eus2/providers/Microsoft.Network/privateEndpoints/pep-stnvhdbxdev-blob-eus2"
}

import {
  to = module.private_endpoints["storage_dfs"].azurerm_private_endpoint.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/privateEndpoints/pep-stnvhdbxdev-dfs-eus2"
}

import {
  to = module.private_endpoints["key_vault"].azurerm_private_endpoint.this
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-nousviahealth-network-dev-eus2/providers/Microsoft.Network/privateEndpoints/pep-kv-nvh-dbx-dev-eus2"
}
