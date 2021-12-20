variable "resource_group_name" {
  type        = string
  description = "Resource group used to deploy resources."
  default     = "dapr-dev-resources"
}

variable "aks_cluster_name" {
  type        = string
  description = "Azure Kubernetes cluster to deploy in."
  default     = "dapr-dev-aks"
}