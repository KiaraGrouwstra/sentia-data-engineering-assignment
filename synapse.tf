resource "azurerm_synapse_workspace" "synapse" {
  name                                 = "${local.prefix}synapse" # alphanumeric
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.lake.id
  managed_virtual_network_enabled      = true
  sql_identity_control_enabled         = true
  managed_resource_group_name          = azurerm_resource_group.rg.name
  sql_administrator_login              = "admin"
  sql_administrator_login_password     = var.synapse_password
  tags                                 = local.default_tags
  github_repo {
    account_name    = "KiaraGrouwstra"
    branch_name     = "main"
    repository_name = "sentia-data-engineering-assignment"
    root_folder     = "/synapse/"
    # git_url = "https://github.sentia.com"
  }
  # azure_devops_repo {
  #   account_name    = "KiaraGrouwstra"
  #   branch_name     = "main"
  #   repository_name = "sentia-data-engineering-assignment"
  #   root_folder     = "/synapse/"
  #   project_name    = "sentia-data-engineering-assignment"
  # }

  aad_admin {
    login     = var.azure_ad_admin
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = var.azure_tenant_id
  }
}

resource "azurerm_synapse_sql_pool" "synapse_sql" {
  name                 = "${local.prefix}_synapse_sql"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  sku_name             = "DW100c" # DW100c, DW200c, DW300c, DW400c, DW500c, DW1000c, DW1500c, DW2000c, DW2500c, DW3000c, DW5000c, DW6000c, DW7500c, DW10000c, DW15000c or DW30000c
  create_mode          = "Default"
  collation            = "Latin1_General_100_BIN2_UTF8"
  data_encrypted       = true
  tags                 = local.default_tags
  # recovery_database_id = ""
  # restore {
  #   point_in_time      = ""
  #   source_database_id = ""
  # }
}

resource "azurerm_synapse_spark_pool" "example" {
  name                 = "${local.prefix}synapsespark" # alphanumeric
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small" # Small, Medium, Large
  spark_log_folder     = "/logs"
  spark_events_folder  = "/events"
  spark_version        = "2.4"
  tags                 = local.default_tags

  # node_count = 3
  auto_scale {
    min_node_count = 3  # 3-200
    max_node_count = 50 # 3-200
  }

  auto_pause {
    delay_in_minutes = 15
  }

  # library_requirement {
  #   content  = ""
  #   filename = ""
  # }
}

# data lake, used by synapse

# requires AAD Storage role
resource "azurerm_storage_data_lake_gen2_filesystem" "lake" {
  name               = "${local.prefix}-lake"
  storage_account_id = azurerm_storage_account.sa.id
  ace {
    # give access to data engineers
    id          = azuread_group.group_data_engineers.object_id
    type        = "group"   # user, group, mask or others
    scope       = "default" # default, access
    permissions = "rwx"
  }
  properties = {}
}
