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
  log_analytics_workspace_name = "dapr-${var.environment}-logsws"
  app_insights_name = "dapr-${var.environment}-appi"
  aks_cluster_name = "dapr-${var.environment}-aks"
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "main" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.main.location
    resource_group_name   = azurerm_log_analytics_workspace.main.resource_group_name
    workspace_resource_id = azurerm_log_analytics_workspace.main.id
    workspace_name        = azurerm_log_analytics_workspace.main.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_application_insights" "main" {
  name                  = local.app_insights_name
  location              = azurerm_log_analytics_workspace.main.location
  resource_group_name   = azurerm_log_analytics_workspace.main.resource_group_name
  workspace_id          = azurerm_log_analytics_workspace.main.id
  application_type      = "web"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "dapraks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  role_based_access_control {
    enabled    = true
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    }
  }

  identity {
    type = "SystemAssigned"
  }
}