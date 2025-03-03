##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group to provision the watsonx.ai resources. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all the resources created by this solution. To not use any prefix value, you can set this value to `null` or an empty string."
  default     = "dev"
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
    condition     = (var.enable_cos_kms_encryption && var.existing_cos_kms_key_crn == null) ? local.kms_region == var.region : true
    error_message = "KMS instance need to be in the same region as of watsonx.ai"
  }
}

variable "resource_tags" {
  description = "Optional list of tags to describe the service instances created by the module."
  type        = list(string)
  default     = []
}

##############################################################################################################
# watsonx.ai Studio
##############################################################################################################

variable "existing_watsonx_ai_studio_instance_crn" {
  default     = null
  description = "The CRN of an existing watsonx.ai Studio instance. If not provided, a new instance will be provisioned."
  type        = string
}

variable "watsonx_ai_studio_plan" {
  default     = "professional-v1"
  description = "The plan that is used to provision the watsonx.ai Studio instance. Allowed values are 'free-v1' and 'professional-v1'. 'free-v1' corresponds to 'Lite' and 'professional-v1' refers to 'Professional' plan on IBM Cloud dashboard."
  type        = string
  validation {
    condition     = contains(["free-v1", "professional-v1"], var.watsonx_ai_studio_plan)
    error_message = "You must use a free-v1 or professional-v1 plan for watsonx.ai Studio. [Learn more](https://cloud.ibm.com/catalog/services/watsonxai-studio)."
  }
}

variable "watsonx_ai_studio_instance_name" {
  type        = string
  description = "The name of the watsonx.ai Studio instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  default     = "watson-ai"
}

###############################################################################################################
# watsonx.ai Runtime
###############################################################################################################

variable "existing_watsonx_ai_runtime_instance_crn" {
  default     = null
  description = "The CRN of an existing watsonx.ai Runtime instance. If not provided, a new instance will be provisioned."
  type        = string
}

variable "watsonx_ai_runtime_instance_name" {
  type        = string
  description = "The name of the watsonx.ai Runtime instance to create. If a prefix input variable is passed, it is prefixed to the value in the `<prefix>-value` format."
  default     = "runtime"
}

variable "watsonx_ai_runtime_plan" {
  description = "The plan that is used to provision the watsonx.ai Runtime instance. Allowed values are 'lite', 'v2-professional' and 'v2-standard'. 'lite' refers to 'Lite', 'v2-professional' corresponds to 'Standard' and 'v2-standard' refers to 'Essentials' plan on IBM Cloud dashboard. For 'lite' plan, the `watsonx_ai_runtime_service_endpoints` value is ignored and the default service configuration is applied."
  type        = string
  default     = "v2-standard"

  validation {
    condition     = contains(["lite", "v2-professional", "v2-standard"], var.watsonx_ai_runtime_plan)
    error_message = "The plan must be lite, v2-professional, or v2-standard for watsonx.ai Runtime. [Learn more](https://cloud.ibm.com/catalog/services/watsonxai-runtime)."
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

###############################################################################################################
# KMS
###############################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the existing key management service (KMS) that is used to create keys for encrypting the Cloud Object Storage bucket. If you are not using an existing KMS root key, you must specify this CRN. If you are using an existing KMS root key, an existing COS instance and auth policy is not set for COS to KMS, you must specify this CRN."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}kms:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS (Key Protect) instance CRN in not valid."
  }
}

variable "existing_cos_kms_key_crn" {
  type        = string
  default     = null
  description = "Optional. The CRN of an existing key management service (Key Protect) key to use to encrypt the Cloud Object Storage bucket that this solution creates. To create a key ring and key, pass a value for the `existing_kms_instance_crn` input variable."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to use for communicating with the Key Protect instance. Possible values: `public`, `private`. Applies only if `existing_cos_kms_key_crn` is not specified."
  default     = "public"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "Valid values for the `kms_endpoint_type_value` are `public` or `private`."
  }
}

variable "kms_key_ring_name" {
  type        = string
  default     = "cos-key-ring"
  description = "The name of the key ring to create for the Cloud Object Storage bucket key. If an existing key is used, this variable is not required. If the prefix input variable is passed, the name of the key ring is prefixed to the value in the `<prefix>-value` format."
}

variable "kms_key_name" {
  type        = string
  default     = "cos-key"
  description = "The name of the key to create for the Cloud Object Storage bucket. If an existing key is used, this variable is not required. If the prefix input variable is passed, the name of the key is prefixed to the value in the `<prefix>-value` format."
}

variable "enable_cos_kms_encryption" {
  description = "Flag to enable COS KMS encryption. If set to true, a value must be passed for `existing_cos_kms_key_crn`."
  type        = bool
  default     = false

  validation {
    condition     = (var.enable_cos_kms_encryption == true && var.existing_cos_kms_key_crn == null) ? (var.existing_kms_instance_crn == null ? false : true) : true
    error_message = "A value must be passed for either 'existing_kms_instance_crn' or 'existing_cos_kms_key_crn' when 'enable_cos_kms_encryption' is set to true."
  }
}

##############################################################################################################
# COS
##############################################################################################################

variable "existing_cos_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing Cloud Object Storage instance. If a CRN is not specified, a new instance of Cloud Object Storage is created."
}

variable "cos_instance_name" {
  type        = string
  default     = "cos"
  description = "The name of the Cloud Object Storage instance to create. If the prefix input variable is passed, the name of the instance is prefixed to the value in the `<prefix>-value` format."
}

variable "cos_plan" {
  default     = "standard"
  description = "The plan that's used to provision the Cloud Object Storage instance."
  type        = string
  validation {
    condition     = contains(["standard"], var.cos_plan)
    error_message = "You must use a standard plan. Standard plan instances are the most common and are recommended for most workloads."
  }
}

variable "cos_instance_tags" {
  type        = list(string)
  description = "A list of optional tags to add to a new Cloud Object Storage instance."
  default     = []
}

variable "cos_instance_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to a new Cloud Object Storage instance."
  default     = []
}

variable "skip_cos_kms_authorization_policy" {
  type        = bool
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy."
  default     = false
}

##############################################################################################################
# watsonx.ai Project
##############################################################################################################

variable "watsonx_ai_project_name" {
  description = "The name of the watsonx.ai project."
  type        = string
  default     = "sample-project"
}

variable "project_description" {
  description = "A description of the watsonx.ai project that is created."
  type        = string
  default     = "The watsonx.ai project created by the watsonx.ai deployable architecture."
}

variable "project_tags" {
  description = "A list of tags associated with the watsonx.ai project. Each tag consists of a string containing up to 255 characters. These tags can include spaces, letters, numbers, underscores, dashes, as well as the symbols # and @."
  type        = list(string)
  default     = ["watsonx-ai"]

  validation {
    condition = alltrue([
      for tag in var.project_tags : can(regex("^[@a-z#A-Z_0-9- ]{1,255}$", tag))
    ])
    error_message = "The project_tags should be upto 255 characters and can include spaces, letters, numbers, _, -, # and @."
  }
}

variable "mark_as_sensitive" {
  description = "Set to true to allow the watsonx.ai project to be created with 'Mark as sensitive' flag. It enforces access restriction and prevents data from being moved out of the project. "
  type        = bool
  default     = false
}
