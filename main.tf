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
      name = "sentia-assignment"
    }
  }
  required_providers {
    # azure is required for PowerBI
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.49"
    }
  }
}

# Configure the Microsoft Azure Provider, see
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference
provider "azurerm" {
  features {}
}
