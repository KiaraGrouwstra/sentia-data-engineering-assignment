# Terraform is a cloud-agnostic infrastructure-as-code tool
terraform {
  # `~>` means we allow require confirmation before performing major upgrades.
  required_version = "~> 0.14.7"
  # it's best practice to store state remotely to enable cooperation.
  backend "remote" {
    # for this PoC I'll be using TerraForm Cloud.
    hostname = "app.terraform.io"
    # personal account, should be a company account for real-life scenarios!
    organization = "cinerealkiara"
    workspaces {
      # workspace will be created automatically if not present.
      name = "sentia-assignment"
    }
  }
  required_providers {
    # azure is required for PowerBI
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.49"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.7"
    }
    powerbi = {
      source  = "codecutout/powerbi"
      version = "~> 1.3"
    }
  }
}

locals {
  # keep prefix short, many names have a 24-char limit. moreover, many resources dislike `-`, some `_`...
  prefix = var.environment
  default_tags = {
    Environment = var.environment
  }
  data_engineers = {
    "jdoe" = {
      user_principal_name = "jdoe@sentia.com"
      display_name        = "J. Doe"
      mail_nickname       = "jdoe"
    }
  }
}

# Configure the Microsoft Azure Provider, see
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference
provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.azurerm_region
  tags     = local.default_tags
}

resource "azuread_group" "group_data_engineers" {
  name        = "${local.prefix}-group-data-engineers"
  description = "data engineers at Sentia's client authorized to access the applications"
  owners      = [data.azurerm_client_config.current.object_id]
  # members = []
  prevent_duplicate_names = true
}

# default passwords for our users
resource "random_password" "passwords" {
  count   = length(local.data_engineers)
  length  = 16
  special = true
}

# users for the data engineering team
resource "azuread_user" "user_data_engineers" {
  for_each            = local.data_engineers
  user_principal_name = each.value.user_principal_name
  display_name        = each.value.display_name
  mail_nickname       = each.value.mail_nickname
  password            = random_password.passwords[index(keys(local.data_engineers), each.key)].result
}

# network

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
  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos.id
    enable = true
  }
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
