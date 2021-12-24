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

variable "acr_name" {
  type        = string
  description = "ACR name"
}

variable "subtract_image_tag" {
  type        = string
  description = "Image tag for substract app"
  default     = "latest"
}