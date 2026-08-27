module "resource_group" {
  source = "./modules/resource-group"

  for_each = local.resource_groups

  name       = each.value.name
  location   = each.value.location
  tags       = each.value.tags
  depends_on = [terraform_data.composition_validation]
}

resource "terraform_data" "composition_validation" {
  input = {
    resource_groups   = local.resource_groups
    networks          = local.networks
    storage_accounts  = local.storage_accounts
    private_endpoints = local.private_endpoints
  }

  lifecycle {
    precondition {
      condition     = var.resource_groups != null || (var.storage_account_name != null && try(trimspace(var.storage_account_name), "") != "")
      error_message = "Provide storage_accounts, or set the legacy storage_account_name when using singular compatibility mode."
    }
    precondition {
      condition     = var.resource_groups == null || (var.networks != null && var.storage_accounts != null && var.private_endpoints != null)
      error_message = "When resource_groups is configured, networks, storage_accounts, and private_endpoints must also be configured as keyed maps."
    }
    precondition {
      condition     = alltrue([for network in local.networks : contains(keys(local.resource_groups), network.resource_group_key)])
      error_message = "Every network.resource_group_key must match a key in resource_groups."
    }
    precondition {
      condition     = alltrue([for account in local.storage_accounts : contains(keys(local.resource_groups), account.resource_group_key)])
      error_message = "Every storage_accounts[*].resource_group_key must match a key in resource_groups."
    }
    precondition {
      condition = alltrue([for endpoint in local.private_endpoints :
        contains(keys(local.resource_groups), endpoint.resource_group_key) &&
        contains(keys(local.networks), endpoint.network_key) &&
        contains(keys(local.storage_accounts), endpoint.storage_account_key)
      ])
      error_message = "Each private endpoint must reference existing resource group, network, and storage account keys."
    }
    precondition {
      condition = alltrue([
        for key, ranges in local.network_ranges : anytrue([
          for vnet_range in ranges.vnets :
          vnet_range.start >= 0 && ranges.subnet.start >= vnet_range.start && ranges.subnet.end <= vnet_range.end
        ])
      ])
      error_message = "Each private endpoint subnet must be fully contained by one of its VNet address ranges."
    }
    precondition {
      condition = alltrue([
        for pair in local.network_pairs : alltrue([
          for left_range in local.network_ranges[pair.left_key].vnets : alltrue([
            for right_range in local.network_ranges[pair.right_key].vnets :
            left_range.start >= 0 && right_range.start >= 0 &&
            !(left_range.start <= right_range.end && right_range.start <= left_range.end)
          ])
        ])
      ])
      error_message = "VNet address ranges for different networks must not overlap."
    }
    precondition {
      condition = length(distinct([
        for network in local.networks : network.private_endpoint_subnet_cidr
      ])) == length(local.networks)
      error_message = "Private endpoint subnet CIDRs must be unique across configured networks."
    }
    precondition {
      condition     = length(distinct(local.network_dns_zone_keys)) == length(local.network_dns_zone_keys)
      error_message = "Only one network may own a private DNS zone name in a given resource group; use distinct zone names or resource groups."
    }
  }
}

module "network" {
  source = "./modules/network"

  for_each = local.networks

  location                     = coalesce(each.value.location, try(module.resource_group[each.value.resource_group_key].location, ""))
  resource_group_name          = try(module.resource_group[each.value.resource_group_key].name, "")
  vnet_name                    = each.value.vnet_name
  vnet_address_space           = each.value.vnet_address_space
  subnet_name                  = each.value.private_endpoint_subnet_name
  private_endpoint_subnet_cidr = each.value.private_endpoint_subnet_cidr
  nsg_name                     = each.value.nsg_name
  private_dns_zone_name        = each.value.private_dns_zone_name
  tags                         = merge(var.tags, each.value.tags)
  depends_on                   = [terraform_data.composition_validation]
}

module "storage" {
  source = "./modules/storage"

  for_each = local.storage_accounts

  location             = coalesce(each.value.location, try(module.resource_group[each.value.resource_group_key].location, ""))
  resource_group_name  = try(module.resource_group[each.value.resource_group_key].name, "")
  storage_account_name = each.value.name
  file_shares          = each.value.file_shares
  replication_type     = each.value.replication_type
  tags                 = merge(var.tags, each.value.tags)
  depends_on           = [terraform_data.composition_validation]
}

module "private_endpoint" {
  source = "./modules/private-endpoint"

  for_each = local.private_endpoints

  location              = coalesce(each.value.location, try(module.resource_group[each.value.resource_group_key].location, ""))
  resource_group_name   = try(module.resource_group[each.value.resource_group_key].name, "")
  private_endpoint_name = each.value.name
  subnet_id             = try(module.network[each.value.network_key].private_endpoint_subnet_id, "")
  storage_account_id    = try(module.storage[each.value.storage_account_key].id, "")
  storage_account_name  = try(module.storage[each.value.storage_account_key].name, "")
  private_dns_zone_id   = try(module.network[each.value.network_key].private_dns_zone_id, "")
  tags                  = merge(var.tags, each.value.tags)
  depends_on            = [terraform_data.composition_validation]
}

moved {
  from = module.resource_group
  to   = module.resource_group["deployment"]
}

moved {
  from = module.network
  to   = module.network["deployment"]
}

moved {
  from = module.storage.azurerm_storage_account.this
  to   = module.storage["storage"].azurerm_storage_account.this
}

moved {
  from = module.storage.azurerm_storage_share.this
  to   = module.storage["storage"].azurerm_storage_share.this["shared"]
}

moved {
  from = module.private_endpoint.azurerm_private_endpoint.files
  to   = module.private_endpoint["storage"].azurerm_private_endpoint.files
}

moved {
  from = module.private_endpoint.azurerm_private_dns_zone.files
  to   = module.network["deployment"].azurerm_private_dns_zone.files
}

moved {
  from = module.private_endpoint.azurerm_private_dns_zone_virtual_network_link.files
  to   = module.network["deployment"].azurerm_private_dns_zone_virtual_network_link.files
}

