# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.72.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4"
    }
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  resource_group_name = data.azurerm_resource_group.main.name
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
  experiments {
      manifest_resource = true
  }
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

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
  }
}

resource "helm_release" "azmonitor" {
  name       = "azmonitor"
  chart      = "../../helm/azmonitor"
  timeout   = 150
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

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "15.6.7"
  namespace = kubernetes_namespace.app.metadata[0].name
  timeout   = 300
}

resource "helm_release" "components" {
  name       = "components"
  chart      = "../../helm/components"
  namespace = kubernetes_namespace.app.metadata[0].name
  timeout   = 150
  depends_on = [
    helm_release.dapr
  ]
}

resource "helm_release" "app" {
  name       = "app"
  chart      = "../../helm/app"
  namespace = kubernetes_namespace.app.metadata[0].name
  timeout   = 300
  depends_on = [
    helm_release.components
  ]

  set {
    name  = "appinsights.instrumentationKey"
    value = data.azurerm_application_insights.main.instrumentation_key
  }
}