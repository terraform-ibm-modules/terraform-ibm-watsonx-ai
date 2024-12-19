########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "The resource group ID where the watsonx services will be provisioned. Required when creating a new instance."
  type        = string
  default     = null
  validation {
    condition     = var.existing_watson_studio_instance_crn == null ? length(var.resource_group_id) > 0 : true
    error_message = "You must specify a value for 'resource_group_id', required to create watson studio instance."
  }

  validation {
    condition     = var.existing_machine_learning_instance_crn == null ? length(var.resource_group_id) > 0 : true
    error_message = "You must specify a value for 'resource_group_id', required to create watson machine learning instance."
  }
}

variable "prefix" {
  description = "The name to be used on all Watson resources as a prefix."
  type        = string

  validation {
    condition     = var.prefix != "" && length(var.prefix) <= 25
    error_message = "You must provide a value for the resource_prefix variable and the resource_prefix length can't exceed 25 characters."
  }
}

variable "region" {
  default     = "us-south"
  description = "Region where the watsonx resources will be provisioned."
  type        = string

  validation {
    condition     = contains(["eu-de", "us-south", "eu-gb", "jp-tok"], var.region)
    error_message = "You must specify `eu-de`, `eu-gb`, `jp-tok` or `us-south` as the IBM Cloud region."
  }
}

# Watson Studio
variable "existing_watson_studio_instance_crn" {
  default     = null
  description = "The CRN of an existing Watson Studio instance. If not provided, a new instance will be provisioned."
  type        = string
}

variable "watson_studio_plan" {
  default     = "free-v1"
  description = "The plan that is used to provision the Watson Studio instance. The plan you choose for Watson Studio affects the features and capabilities that you can use."
  type        = string
  validation {
    condition     = contains(["free-v1", "professional-v1"], var.watson_studio_plan)
    error_message = "You must use a free-v1 or professional-v1 plan. Learn more."
  }
}

# Watson Machine Learning
variable "existing_machine_learning_instance_crn" {
  default     = null
  description = "The CRN of an existing Watson Machine Learning instance. If not provided, a new instance will be provisioned."
  type        = string
}

variable "watson_machine_learning_plan" {
  description = "The plan that is used to provision the Watson Machine Learning instance."
  type        = string
  default     = "lite"

  validation {
    condition     = contains(["lite", "v2-professional", "v2-standard"], var.watson_machine_learning_plan)
    error_message = "The plan must be lite, v2-professional, or v2-standard. Learn more."
  }
}

variable "watson_machine_learning_service_endpoints" {
  type        = string
  description = "The type of service endpoints. Possible values: 'public', 'private', 'public-and-private'."
  default     = "public"

  validation {
    condition     = contains(["public", "public-and-private", "private"], var.watson_machine_learning_service_endpoints)
    error_message = "The specified service endpoint is not valid. Supported options are public, public-and-private, or private."
  }

  validation {
    condition     = contains(["lite"], var.watson_machine_learning_plan) ? contains(["public"], var.watson_machine_learning_service_endpoints) : true
    error_message = "The lite plan of watson machine learning only supports public endpoints."
  }
}

# COS-KMS

variable "enable_cos_kms_encryption" {
  description = "Flag to enable COS KMS encryption. If set to true, a value must be passed for `existing_cos_kms_key_crn`."
  type        = bool
  default     = false
}

variable "cos_instance_crn" {
  description = "The CRN of the Cloud Object Storage instance."
  type        = string
}

variable "cos_kms_key_crn" {
  description = "The CRN of a KMS key. It is used to encrypt the COS buckets used by the watsonx projects."
  type        = string
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy."
  default     = false
}

# Watsonx Project

variable "enable_configure_project" {
  description = "Whether to configure project."
  type        = bool
  default     = true
}

variable "watsonx_project_name" {
  description = "The name of the Watsonx.ai project."
  type        = string
  default     = "demo"
}

variable "watsonx_project_description" {
  description = "A description of the Watsonx.ai project that is created."
  type        = string
  default     = "Watsonx project created by the watsonx.ai module."
}

variable "watsonx_project_tags" {
  description = "A list of tags associated with the watsonx.ai project. Each tag consists of a single string containing up to 255 characters. These tags can include spaces, letters, numbers, underscores, dashes, as well as the symbols # and @."
  type        = list(string)
  default     = []
}

variable "watsonx_mark_as_sensitive" {
  description = "Set to true to allow the Watsonx.ai project to be created with 'Mark as sensitive' flag."
  type        = bool
  default     = false
}
