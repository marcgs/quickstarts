# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.72.0"
    }
  }
}

provider "azurerm" {
    features {
    }
}


locals {
  resource_group_name = "dapr-${var.environment}-resources"
}

resource "azurerm_resource_group" "core-resourcegroup" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    "usage" : "learning"
  }
}
