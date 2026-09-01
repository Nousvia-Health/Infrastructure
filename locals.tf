locals {
  resource_groups = coalesce(var.resource_groups, {
    deployment = {
      name     = coalesce(var.resource_group_name, "rg-azure-files-dev")
      location = var.location
      tags     = var.tags
    }
  })

  networks = coalesce(var.networks, {
    deployment = {
      resource_group_key           = "deployment"
      vnet_name                    = "vnet-${coalesce(var.storage_account_name, "azure-files")}"
      vnet_address_space           = var.vnet_address_space
      private_endpoint_subnet_name = "snet-private-endpoints"
      private_endpoint_subnet_cidr = var.private_endpoint_subnet_cidr
      nsg_name                     = "nsg-${coalesce(var.storage_account_name, "azure-files")}-private-endpoints"
      private_dns_zone_name        = "privatelink.file.core.windows.net"
      location                     = null
      tags                         = {}
    }
  })

  storage_accounts = coalesce(var.storage_accounts, {
    storage = {
      resource_group_key             = "deployment"
      name                           = var.storage_account_name
      replication_type               = var.storage_account_replication_type
      default_share_level_permission = var.azure_files_default_share_level_permission
      file_shares = {
        shared = {
          name             = coalesce(var.file_share_name, "shared")
          quota_gb         = coalesce(var.file_share_quota_gb, 100)
          role_assignments = var.file_share_role_assignments
        }
      }
      location = null
      tags     = {}
    }
  })

  private_endpoints = coalesce(var.private_endpoints, {
    storage = {
      resource_group_key  = "deployment"
      network_key         = "deployment"
      storage_account_key = "storage"
      name                = "pe-${coalesce(var.storage_account_name, "azure-files")}-file"
      location            = null
      tags                = {}
    }
  })

  network_pairs = flatten([
    for left_key, left_network in local.networks : [
      for right_key, right_network in local.networks : {
        left_key  = left_key
        left      = left_network
        right_key = right_key
        right     = right_network
      } if left_key != right_key
    ]
  ])

  network_dns_zone_keys = [
    for network in local.networks : "${network.resource_group_key}|${network.private_dns_zone_name}"
  ]

  network_ranges = {
    for key, network in local.networks : key => {
      vnets = [
        for cidr in network.vnet_address_space : {
          start = try(sum([for index, octet in split(".", cidrhost(cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]), -1)
          end   = try(sum([for index, octet in split(".", cidrhost(cidr, -1)) : tonumber(octet) * pow(256, 3 - index)]), -1)
        }
      ]
      subnet = {
        start = try(sum([for index, octet in split(".", cidrhost(network.private_endpoint_subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - index)]), -1)
        end   = try(sum([for index, octet in split(".", cidrhost(network.private_endpoint_subnet_cidr, -1)) : tonumber(octet) * pow(256, 3 - index)]), -1)
      }
    }
  }
}
