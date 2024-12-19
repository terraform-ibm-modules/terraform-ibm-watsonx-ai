########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud API Key."
  sensitive   = true
  type        = string
}

variable "prefix" {
  type        = string
  description = "Prefix for the name of all resource created by this example."
  default     = "wx"

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example."
  default     = "us-south"

  validation {
    condition     = contains(["eu-de", "eu-gb", "jp-tok", "us-south"], var.region)
    error_message = "The IBM Cloud region to use must be one of: eu-de, eu-gb, jp-tok or us-south."
  }
}

variable "resource_group" {
  type        = string
  description = "The name of a new or an existing resource group where the resources are created."
  default     = "Default"
}
