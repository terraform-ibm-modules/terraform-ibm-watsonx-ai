variable "resource_group_id" {
  description = "ID of the IBM Cloud resource group in which resources are created."
  type        = string
}

variable "region" {
  description = "The location that's used with the IBM Cloud Terraform IBM provider. It's also used during resource creation."
  type        = string
}
