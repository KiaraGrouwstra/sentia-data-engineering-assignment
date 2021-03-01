# https://azuremarketplace.microsoft.com/en-us/marketplace/apps/couchbase.couchbase-server-enterprise-container?tab=PlansAndPrice
# https://docs.couchbase.com/server/current/cloud/couchbase-azure-marketplace.html
resource "azurerm_marketplace_agreement" "couchbase" {
  publisher = "couchbase"
  offer     = "couchbase-server-enterprise-container"
  plan      = "byol"
}
