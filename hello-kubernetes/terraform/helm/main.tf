# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.72.0"
    }
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  resource_group_name = data.azurerm_resource_group.main.name
}

provider "azurerm" {
    features {
    }
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
  username               = data.azurerm_kubernetes_cluster.main.kube_config.0.username
  password               = data.azurerm_kubernetes_cluster.main.kube_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  debug = true
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
    username               = data.azurerm_kubernetes_cluster.main.kube_config.0.username
    password               = data.azurerm_kubernetes_cluster.main.kube_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "dapr-system" {
  metadata {
    name = "dapr-system"
  }
}

resource "helm_release" "dapr" {
  name       = "dapr"
  repository = "https://dapr.github.io/helm-charts"
  chart      = "dapr"
  version    = "1.5.1"
  namespace = kubernetes_namespace.dapr-system.metadata[0].name
  timeout   = 300

  #set {
  #  name  = "global.ha.enabled"
  #  value = true
  #}
}
