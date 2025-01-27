########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "The resource group ID where the watsonx services will be provisioned. Required when creating a new instance."
  type        = string
  default     = null
  validation {
    condition     = var.existing_watsonx_ai_studio_instance_crn == null ? length(var.resource_group_id) > 0 : true
    error_message = "You must specify a value for 'resource_group_id', if 'existing_watsonx_ai_studio_instance_crn' is null."
  }

  validation {
    condition     = var.existing_watsonx_ai_runtime_instance_crn == null ? length(var.resource_group_id) > 0 : true
    error_message = "You must specify a value for 'resource_group_id', if 'existing_watsonx_ai_runtime_instance_crn' is null."
  }
}

variable "prefix" {
  description = "Prefix to add to all watsonx.ai resources created by this module."
  type        = string
}

variable "region" {
  default     = "us-south"
  description = "Region where the watsonx.ai resources will be provisioned."
  type        = string

  validation {
    condition     = contains(["eu-de", "us-south", "eu-gb", "jp-tok"], var.region)
    error_message = "You must specify `eu-de`, `eu-gb`, `jp-tok` or `us-south` as the IBM Cloud region."
  }

  validation {
    condition     = var.cos_kms_key_crn != null ? local.kms_region == var.region : true
    error_message = "KMS instance need to be in the same region as of watsonx.ai"
  }
}

variable "resource_tags" {
  description = "Optional list of tags to describe the service instances created by the module."
  type        = list(string)
  default     = []
}

# watsonx.ai Studio
variable "existing_watsonx_ai_studio_instance_crn" {
  default     = null
  description = "The CRN of an existing watsonx.ai Studio instance. If not provided, a new instance will be provisioned."
  type        = string
}

variable "watsonx_ai_studio_plan" {
  default     = "free-v1"
  description = "The plan that is used to provision the watsonx.ai Studio instance. Allowed values are 'free-v1' and 'professional-v1'."
  type        = string
  validation {
    condition     = contains(["free-v1", "professional-v1"], var.watsonx_ai_studio_plan)
    error_message = "You must use a free-v1 or professional-v1 plan for watsonx.ai Studio."
  }
}

variable "watsonx_ai_studio_instance_name" {
  type        = string
  description = "The name of the watsonx.ai Studio instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  default     = "watsonx-studio"
}

variable "existing_watsonx_ai_runtime_instance_crn" {
  default     = null
  description = "The CRN of an existing watsonx.ai Runtime instance. If not provided, a new instance will be provisioned."
  type        = string
}

variable "watsonx_ai_runtime_instance_name" {
  type        = string
  description = "The name of the watsonx.ai Runtime instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  default     = "watsonx-ml"
}

variable "watsonx_ai_runtime_plan" {
  description = "The plan that is used to provision the watsonx.ai Runtime instance. Allowed values are 'lite', 'v2-professional' and 'v2-standard'. For 'lite' plan, the `watsonx_ai_runtime_service_endpoints` value is ignored and the default service configuration is applied."
  type        = string
  default     = "lite"

  validation {
    condition     = contains(["lite", "v2-professional", "v2-standard"], var.watsonx_ai_runtime_plan)
    error_message = "The plan must be lite, v2-professional, or v2-standard for watsonx.ai Runtime."
  }
}

variable "watsonx_ai_runtime_service_endpoints" {
  type        = string
  description = "The type of service endpoints for watsonx.ai Runtime. Possible values: 'public', 'private', 'public-and-private'."
  default     = "public"

  validation {
    condition     = contains(["public", "public-and-private", "private"], var.watsonx_ai_runtime_service_endpoints)
    error_message = "The specified service endpoint is not valid. Supported options are public, public-and-private, or private."
  }
}

# COS & KMS
variable "enable_cos_kms_encryption" {
  description = "Flag to enable COS KMS encryption. If set to true, a value must be passed for `cos_kms_key_crn`."
  type        = bool
  default     = false

  validation {
    condition     = var.enable_cos_kms_encryption == true ? var.cos_kms_key_crn != null : true
    error_message = "A value must be passed for 'cos_kms_key_crn' when 'enable_cos_kms_encryption' is set to true."
  }
}

variable "cos_instance_crn" {
  description = "The CRN of the Cloud Object Storage instance."
  type        = string
}

variable "cos_kms_key_crn" {
  description = "The CRN of a KMS (Key Protect) key. It is used to encrypt the COS buckets used by the watsonx.ai projects."
  type        = string
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy."
  default     = false
}

# watsonx.ai Project
variable "create_watsonx_ai_project" {
  description = "Whether to create and configure a starter watsonx.ai project."
  type        = bool
  default     = true
}

variable "project_name" {
  description = "The name of the watsonx.ai project."
  type        = string
  default     = "demo"
}

variable "project_description" {
  description = "A description of the watsonx.ai project that is created."
  type        = string
  default     = "Watsonx project created by the watsonx.ai module."
}

variable "project_tags" {
  description = "A list of tags associated with the watsonx.ai project. Each tag consists of a string containing up to 255 characters. These tags can include spaces, letters, numbers, underscores, dashes, as well as the symbols # and @."
  type        = list(string)
  default     = ["watsonx-ai"]

  validation {
    condition = alltrue([
      for tag in var.project_tags : can(regex("^[@a-z#A-Z_0-9- ]{1,255}$", tag))
    ])
    error_message = "project_tags should be upto 255 characters and can include spaces, letters, numbers, _, -, # and @."
  }
}

variable "mark_as_sensitive" {
  description = "Set to true to allow the watsonx.ai project to be created with 'Mark as sensitive' flag. It enforces access restriction and prevents data from being moved out of the project. "
  type        = bool
  default     = false
}
