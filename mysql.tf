# https://docs.microsoft.com/en-us/rest/api/mysql/servers/create
resource "azurerm_mysql_server" "mysql" {
  name                         = "${local.prefix}-mysql-server"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  administrator_login          = "admin"
  administrator_login_password = var.mysql_password
  threat_detection_policy {
    enabled                    = true
    disabled_alerts            = []
    email_account_admins       = true
    email_addresses            = var.emails
    retention_days             = 30
    storage_account_access_key = azurerm_storage_account.sa.primary_access_key
    storage_endpoint           = azurerm_storage_account.sa.primary_blob_endpoint
  }

  sku_name   = "B_Gen5_2" # tier, family, cores; B_Gen5_2 is cheap
  storage_mb = 5120       # minimum
  version    = "8.0"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  tags = local.default_tags
}

resource "azurerm_mysql_configuration" "mysql_config" {
  name                = "${local.prefix}-mysql-config"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  value               = "600"
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = "${local.prefix}-mysql-db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
