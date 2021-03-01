# TODO: AD PowerBI licenses

# Configure the Power BI Provider
provider "powerbi" {
  tenant_id     = var.azure_tenant_id
  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret
}

# Create a workspace
resource "powerbi_workspace" "pbi" {
  name = "${local.prefix}-pbi"
}
