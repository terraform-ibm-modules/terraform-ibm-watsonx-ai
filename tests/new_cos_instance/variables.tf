variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "wx-ai"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example. If unset a new resource group will be created"
  default     = null
}
