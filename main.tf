module "resource_groups" {
  source   = "./modules/resource-group"
  for_each = var.resource_groups

  name     = each.value.name
  location = each.value.location
  tags     = merge(var.common_tags, each.value.tags)
}

module "network" {
  source = "./modules/network"
  count  = var.network == null ? 0 : 1

  resource_group_name         = var.network.resource_group_name
  vnet_name                   = var.network.vnet_name
  address_space               = var.network.address_space
  private_endpoint_subnet     = var.network.private_endpoint_subnet
  integration_subnet          = var.network.integration_subnet
  dbx_host_subnet_name        = var.network.dbx_host_subnet_name
  dbx_container_subnet_name   = var.network.dbx_container_subnet_name
  nsg_name                    = var.network.nsg_name
  nat_gateway_name            = var.network.nat_gateway_name
  nat_gateway_subnet_name     = var.network.nat_gateway_subnet_name
  public_ip_name              = var.network.public_ip_name
  public_ip_tags              = var.network.public_ip_tags
  common_tags                 = var.common_tags
  nsg_ownership               = var.network.nsg_ownership
  private_dns_zone_link_names = var.network.private_dns_zone_link_names
}

module "storage" {
  source = "./modules/storage"
  count  = var.storage == null ? 0 : 1

  resource_group_name           = var.storage.resource_group_name
  name                          = var.storage.name
  account_replication_type      = var.storage.account_replication_type
  public_network_access_enabled = var.storage.public_network_access_enabled
  shared_access_key_enabled     = var.storage.shared_access_key_enabled
  tags                          = var.common_tags
}

module "access_connector" {
  source = "./modules/access-connector"
  count  = var.access_connector == null ? 0 : 1

  resource_group_name = var.access_connector.resource_group_name
  name                = var.access_connector.name
  tags                = merge(var.common_tags, var.access_connector.tags)
}

module "key_vault" {
  source = "./modules/key-vault"
  count  = var.key_vault == null ? 0 : 1

  resource_group_name           = var.key_vault.resource_group_name
  name                          = var.key_vault.name
  public_network_access_enabled = var.key_vault.public_network_access_enabled
  purge_protection_enabled      = var.key_vault.purge_protection_enabled
  tags                          = merge(var.common_tags, var.key_vault.tags)
}

module "monitoring" {
  source = "./modules/monitoring"
  count  = var.monitoring == null ? 0 : 1

  resource_group_name        = var.monitoring.resource_group_name
  name                       = var.monitoring.name
  retention_in_days          = var.monitoring.retention_in_days
  internet_ingestion_enabled = var.monitoring.internet_ingestion_enabled
  internet_query_enabled     = var.monitoring.internet_query_enabled
  diagnostic_settings        = var.monitoring.diagnostic_settings
  tags                       = var.common_tags
}

module "databricks" {
  source = "./modules/databricks"
  count  = var.databricks == null ? 0 : 1

  resource_group_name           = var.databricks.resource_group_name
  name                          = var.databricks.name
  managed_resource_group_name   = var.databricks.managed_resource_group_name
  sku                           = var.databricks.sku
  custom_public_subnet_name     = var.databricks.custom_public_subnet_name
  custom_private_subnet_name    = var.databricks.custom_private_subnet_name
  storage_account_sku_name      = var.databricks.storage_account_sku_name
  public_network_access_enabled = var.databricks.public_network_access_enabled
  generated_resource_ownership  = var.databricks.generated_resource_ownership
  vnet_id                       = module.network[0].vnet_id
  tags                          = var.databricks.tags
  common_tags                   = var.common_tags
}

module "private_endpoints" {
  source   = "./modules/private-endpoint"
  for_each = var.private_endpoints

  resource_group_name          = each.value.resource_group_name
  name                         = each.value.name
  subnet_id                    = each.value.subnet_id
  target_resource_id           = each.value.target_resource_id
  subresource_names            = each.value.subresource_names
  dns_zone_names               = each.value.dns_zone_names
  dns_zone_resource_group_name = each.value.dns_zone_resource_group_name
  tags                         = var.common_tags
}

module "network_watcher" {
  source = "./modules/network-watcher"
  count  = var.network_watcher == null ? 0 : 1

  resource_group_name = var.network_watcher.resource_group_name
  name                = var.network_watcher.name
  location            = var.network_watcher.location
  tags                = var.common_tags
}
