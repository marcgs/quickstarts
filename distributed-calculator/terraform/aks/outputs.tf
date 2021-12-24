output "resource_group_name" {
  value = local.resource_group_name
}

output "aks_cluster_name" {
  value = local.aks_cluster_name
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "application_insights_name" {
  value       = azurerm_application_insights.main.name
  description = "The Application Insights resource name."
}

output "container_registry_name" {
  value       = azurerm_container_registry.acr.name
  description = "The Container Registy resource name."
}