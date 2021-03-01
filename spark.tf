# Azure also offers HDInsight Spark, but Databricks is simpler, coming with less of the Hadoop-based overhead
resource "azurerm_databricks_workspace" "spark" {
  name                        = "${local.prefix}-databricks"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  sku                         = "standard" # trial -> standard -> premium
  managed_resource_group_name = azurerm_resource_group.rg.name
  custom_parameters {
    no_public_ip        = true
    virtual_network_id  = azurerm_virtual_network.vnet.id
    private_subnet_name = azurerm_subnet.subnet.name
    # public_subnet_name  = azurerm_subnet.subnet.name
  }
  tags = local.default_tags
}
