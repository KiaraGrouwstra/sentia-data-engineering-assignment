resource "azurerm_storage_account" "sa" {
  name                      = "${local.prefix}sa" # alphanumeric
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_kind              = "StorageV2" # https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
  account_tier              = "Standard"  # Standard -> Premium
  account_replication_type  = "LRS"       # https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview#storage-account-redundancy
  access_tier               = "Hot"       # Cool -> Hot
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = local.default_tags
}

resource "azurerm_storage_account_network_rules" "storage_nwr" {
  resource_group_name        = azurerm_resource_group.rg.name
  storage_account_name       = azurerm_storage_account.sa.name
  default_action             = "Allow"
  ip_rules                   = ["127.0.0.1"]
  virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  bypass                     = ["Logging", "Metrics", "AzureServices"]
}
