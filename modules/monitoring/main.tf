variable "resource_group_name" { type = string }
variable "name" { type = string }
variable "retention_in_days" { type = number }
variable "internet_ingestion_enabled" { type = bool }
variable "internet_query_enabled" { type = bool }
variable "diagnostic_settings" {
  type = map(object({
    target_resource_id = string
    log_categories     = optional(list(string), [])
    metric_categories  = optional(list(string), [])
  }))
}
variable "tags" { type = map(string) }

resource "azurerm_log_analytics_workspace" "this" {
  name                       = var.name
  location                   = "eastus2"
  resource_group_name        = var.resource_group_name
  sku                        = "PerGB2018"
  retention_in_days          = var.retention_in_days
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  tags                       = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each                   = var.diagnostic_settings
  name                       = each.key
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
      enabled  = true
    }
  }
}

output "id" { value = azurerm_log_analytics_workspace.this.id }
