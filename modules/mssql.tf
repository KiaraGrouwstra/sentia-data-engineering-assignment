resource "azurerm_mssql_server" "mssql" {
  name                          = "${local.prefix}-mssql"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = "admin"
  administrator_login_password  = var.mssql_password
  minimum_tls_version           = "1.2"
  connection_policy             = "Default"
  public_network_access_enabled = false
  tags                          = local.default_tags

  azuread_administrator {
    login_username = var.azure_ad_admin
    object_id      = data.azurerm_client_config.current.object_id
    tenant_id      = var.azure_tenant_id
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "mssql_eap" {
  server_id                               = azurerm_mssql_server.mssql.id
  storage_endpoint                        = azurerm_storage_account.sa.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.sa.primary_access_key
  storage_account_access_key_is_secondary = true
  retention_in_days                       = 6
}
