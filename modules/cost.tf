resource "azurerm_cost_management_export_resource_group" "cost" {
  name                    = "${local.prefix}cost" # alphanumeric
  resource_group_id       = azurerm_resource_group.rg.id
  recurrence_type         = "Daily"
  recurrence_period_start = "2021-02-27T00:00:00Z"
  recurrence_period_end   = "2021-03-27T00:00:00Z"

  delivery_info {
    storage_account_id = azurerm_storage_account.sa.id
    container_name     = "cost_management_export"
    root_folder_path   = "/root/updated"
  }

  query {
    type       = "Usage"
    time_frame = "WeekToDate"
  }
}
