resource "azurerm_cosmosdb_account" "cosmos" {
  name                          = "${local.prefix}-cosmos"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  offer_type                    = "Standard"
  kind                          = "MongoDB" # GlobalDocumentDB or MongoDB
  public_network_access_enabled = false
  enable_automatic_failover     = true
  key_vault_key_id              = azurerm_key_vault.keyvault.id
  tags                          = local.default_tags
  enable_free_tier              = true
  # ip_range_filter = "0.0.0.0,0.0.0.0"

  # capabilities {
  #   name = "EnableAggregationPipeline"
  # }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness" # BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
    zone_redundant    = false
  }

  # geo_location {
  #   location          = var.failover_location
  #   failover_priority = 1
  #   zone_redundant    = true
  # }
}

resource "azurerm_cosmosdb_mongo_database" "cosmos_mongo_db" {
  name                = "${local.prefix}-cosmos-mongo-db"
  resource_group_name = azurerm_cosmosdb_account.cosmos.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400
}

# example collection
resource "azurerm_cosmosdb_mongo_collection" "cosmos_mongo_collection" {
  name                = "${local.prefix}-cosmos-mongo-collection"
  resource_group_name = azurerm_cosmosdb_account.cosmos.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_mongo_database.cosmos_mongo_db.name

  default_ttl_seconds = "777"
  shard_key           = var.mongo_shard_key # The name of the key to partition on for sharding. There must not be any other unique index keys.
  throughput          = 400
}
