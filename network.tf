resource "azurerm_network_security_group" "nsg" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.default_tags
}

resource "azurerm_network_ddos_protection_plan" "ddos" {
  name                = "${local.prefix}-ddos"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.default_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  # ddos_protection_plan {
  #   id     = azurerm_network_ddos_protection_plan.ddos.id
  #   enable = true
  # }
  # enable VM protection for all the subnets in this Virtual Network
  vm_protection_enabled = true
  tags                  = local.default_tags
}

resource "azurerm_network_security_rule" "nsr_out" {
  name                        = "${local.prefix}-nsr_out"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  description                 = "Allow outbound traffic"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  # source_application_security_group_ids = []
  # destination_application_security_group_ids = []
}

resource "azurerm_network_security_rule" "nsr_in" {
  name                        = "${local.prefix}-nsr_in"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  description                 = "Allow inbound traffic within the virtual network"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  # source_application_security_group_ids = []
  # destination_application_security_group_ids = []
}

resource "azurerm_virtual_wan" "vwan" {
  name                = "${local.prefix}-vwan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.default_tags
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "${local.prefix}-vhub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.0.1.0/24"
  tags                = local.default_tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  # delegation {
  #   name = "delegation"

  #   service_delegation {
  #     name    = "Microsoft.ContainerInstance/containerGroups"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #   }
  # }
}
