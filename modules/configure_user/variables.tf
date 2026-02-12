variable "resource_group_id" {
  description = "The resource group ID where resources will be created."
  type        = string
}

variable "region" {
  description = "Region to be used for the watsonx resources creation."
  type        = string
}

variable "install_required_binaries" {
  type        = bool
  default     = true
  description = "When set to true, a script will run to check if `jq` exist on the runtime and if not attempt to download it from the public internet and install it to /tmp. Set to false to skip running this script."
  nullable    = false
}
