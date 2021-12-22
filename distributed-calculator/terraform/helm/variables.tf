variable "resource_group_name" {
  type        = string
  description = "Resource group used to deploy resources."
  default     = "dapr-distcalculator-resources"
}

variable "application_insights_name" {
  type        = string
  description = "Azure Kubernetes cluster to deploy in."
  default     = "dapr-distcalculator-appi"
}

variable "aks_cluster_name" {
  type        = string
  description = "Azure Kubernetes cluster to deploy in."
  default     = "dapr-distcalculator-aks"
}