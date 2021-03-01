resource "azurerm_log_analytics_workspace" "log_analytics_ws" {
  name                              = "${local.prefix}-log-analytics-ws"
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  daily_quota_gb                    = 10
  retention_in_days                 = 30
  internet_ingestion_enabled        = false
  internet_query_enabled            = false
  reservation_capcity_in_gb_per_day = 100
  tags                              = local.default_tags
}

resource "azurerm_network_watcher" "network_watcher" {
  name                = "${local.prefix}-network-watcher"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.default_tags
}

resource "azurerm_network_watcher_flow_log" "network_watcher_flow_log" {
  network_watcher_name = azurerm_network_watcher.network_watcher.name
  resource_group_name  = azurerm_resource_group.rg.name

  network_security_group_id = azurerm_network_security_group.nsg.id
  storage_account_id        = azurerm_storage_account.sa.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.log_analytics_ws.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.log_analytics_ws.location
    workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_ws.id
    interval_in_minutes   = 10
  }
}
