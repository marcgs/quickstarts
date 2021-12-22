variable "environment" {
  type        = string
  description = "Second part of name prefix used in naming resources. Use only lowercase letters and numbers."
  default     = "distcalculator"
}

variable "location" {
  type        = string
  description = "Resource group used to deploy resources."
  default     = "westeurope"
}