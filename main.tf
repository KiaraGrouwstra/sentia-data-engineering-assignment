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

# let the admin belong to any groups
resource "azuread_group_member" "member_admin" {
  # for_each         = [azuread_group.group_data_engineers]
  group_object_id  = azuread_group.group_data_engineers.id # TODO: each.value
  member_object_id = data.azurerm_client_config.current.object_id
}
