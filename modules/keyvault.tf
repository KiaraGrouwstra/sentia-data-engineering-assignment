resource "azurerm_key_vault" "keyvault" {
  name                        = "${local.prefix}-keyvault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.azure_tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard" # standard -> premium
  tags                        = local.default_tags
}

resource "azurerm_key_vault_access_policy" "kvap" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = var.azure_tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  # application_id = ""

  key_permissions = [
    "Get",
  ]

  storage_permissions = [
    "Get",
  ]

  # secret_permissions = [
  #   "Get",
  # ]

  # certificate_permissions = [
  #   "Get",
  # ]
}
