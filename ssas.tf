resource "azurerm_analysis_services_server" "server" {
  name                      = "${local.prefix}ssas" # alphanumeric
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  sku                       = "S0" # D1, B1, B2, S0, S1, S2, S4, S8, S9, S8v2, S9v2
  admin_users               = var.emails
  enable_power_bi_service   = true
  querypool_connection_mode = "All" # All, ReadOnly
  backup_blob_container_uri = azurerm_storage_account.sa.primary_blob_endpoint
  tags                      = local.default_tags

  # ipv4_firewall_rule {
  #   name        = "myRule1"
  #   range_start = "210.117.252.0"
  #   range_end   = "210.117.252.255"
  # }
}
