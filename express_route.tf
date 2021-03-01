# https://docs.microsoft.com/en-us/azure/expressroute/
resource "azurerm_express_route_circuit" "erc" {
  name                  = "${local.prefix}-erc"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  peering_location      = "Amsterdam" # https://docs.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers#global-commercial-azure
  service_provider_name = "Equinix"   # belongs to Amsterdam, Interxion to Amsterdam2
  bandwidth_in_mbps     = 50
  tags                  = local.default_tags

  sku {
    tier   = "Standard"    # Basic, Local, Premium, Standard
    family = "MeteredData" # MeteredData, UnlimitedData
  }
}

resource "azurerm_express_route_circuit_authorization" "erc_auth" {
  name                       = "${local.prefix}-erc-auth"
  resource_group_name        = azurerm_resource_group.rg.name
  express_route_circuit_name = azurerm_express_route_circuit.erc.name
}

resource "azurerm_express_route_gateway" "ergw" {
  name                = "${local.prefix}-ergw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_hub_id      = azurerm_virtual_hub.vhub.id
  scale_units         = 1 # Each scale unit is equal to 2Gbps, with support for up to 10 scale units (20Gbps).
  tags                = local.default_tags
}

resource "azurerm_express_route_circuit_peering" "erc_peer" {
  peering_type                  = "MicrosoftPeering" # AzurePrivatePeering, AzurePublicPeering, MicrosoftPeering
  resource_group_name           = azurerm_resource_group.rg.name
  express_route_circuit_name    = azurerm_express_route_circuit.erc.name
  peer_asn                      = 100            # The Either a 16-bit or a 32-bit ASN. Can either be public or private.
  primary_peer_address_prefix   = "123.0.0.0/30" # A /30 subnet for the primary link.
  secondary_peer_address_prefix = "123.0.0.4/30" # A /30 subnet for the secondary link.
  vlan_id                       = 300            # A valid VLAN ID to establish this peering on.
  # shared_key                    = ""             # The shared key. 1-25 characters.
  # route_filter_id               = ""             # The ID of the Route Filter. Only available when peering_type is set to MicrosoftPeering.

  microsoft_peering_config {
    advertised_public_prefixes = ["123.1.0.0/24"]
    customer_asn               = 1
    routing_registry_name      = "ARIN" # e.g. ARIN, RIPE, AFRINIC
  }

  ipv6 {
    primary_peer_address_prefix   = "2002:db01::/126"
    secondary_peer_address_prefix = "2003:db01::/126"
    # route_filter_id               = "" # The ID of the Route Filter. Only available when peering_type is set to MicrosoftPeering.

    microsoft_peering {
      advertised_public_prefixes = ["2002:db01::/126"]
      customer_asn               = 1
      routing_registry_name      = "ARIN" # e.g. ARIN, RIPE, AFRINIC
    }
  }
}
