resource "azurerm_data_factory" "adf" {
  name                   = "${local.prefix}-adf"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  public_network_enabled = false
  tags                   = local.default_tags
}
