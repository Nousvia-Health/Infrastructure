variable "resource_group_name" { type = string }
variable "name" { type = string }
variable "managed_resource_group_name" { type = string }
variable "sku" { type = string }
variable "custom_public_subnet_name" { type = string }
variable "custom_private_subnet_name" { type = string }
variable "storage_account_sku_name" { type = string }
variable "vnet_id" { type = string }
variable "tags" { type = map(string) }
variable "public_network_access_enabled" { type = bool }
variable "generated_resource_ownership" { type = string }

resource "azurerm_databricks_workspace" "this" {
  name                                  = var.name
  resource_group_name                   = var.resource_group_name
  location                              = "eastus2"
  sku                                   = var.sku
  managed_resource_group_name           = var.managed_resource_group_name
  public_network_access_enabled         = var.public_network_access_enabled
  network_security_group_rules_required = "AllRules"
  infrastructure_encryption_enabled     = false
  tags                                  = var.tags

  lifecycle {
    precondition {
      condition     = var.generated_resource_ownership == "databricks"
      error_message = "Databricks-generated resources must remain owned by the Databricks service, not Terraform."
    }
    precondition {
      condition     = var.managed_resource_group_name != var.resource_group_name
      error_message = "The Databricks managed resource group must be distinct from the customer resource group."
    }
  }

  custom_parameters {
    virtual_network_id                                   = var.vnet_id
    no_public_ip                                         = true
    public_subnet_name                                   = var.custom_public_subnet_name
    private_subnet_name                                  = var.custom_private_subnet_name
    public_subnet_network_security_group_association_id  = data.azurerm_subnet.public.network_security_group_id
    private_subnet_network_security_group_association_id = data.azurerm_subnet.private.network_security_group_id
    storage_account_sku_name                             = var.storage_account_sku_name
  }
}

data "azurerm_subnet" "public" {
  name                 = var.custom_public_subnet_name
  virtual_network_name = split("/", var.vnet_id)[8]
  resource_group_name  = split("/", var.vnet_id)[4]
}

data "azurerm_subnet" "private" {
  name                 = var.custom_private_subnet_name
  virtual_network_name = split("/", var.vnet_id)[8]
  resource_group_name  = split("/", var.vnet_id)[4]
}

output "workspace_url" { value = azurerm_databricks_workspace.this.workspace_url }
output "id" { value = azurerm_databricks_workspace.this.id }
