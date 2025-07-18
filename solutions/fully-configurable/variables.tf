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

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group in which the watsonx.ai instance will be provisioned."
  default     = "Default"
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits and hyphens ('-'). It should not exceed 16 characters, must not end with a hyphen ('-'), and can not contain consecutive hyphens ('--'). Example: wx-54-ai. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)"

  validation {
    condition = var.prefix == null || var.prefix == "" ? true : alltrue([
      can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)), length(regexall("--", var.prefix)) == 0
    ])
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens ('-'). It must not end with a hyphen ('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
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
  description = "Optional list of tags to describe the watsonx_ai runtime and studio instances created by the module."
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
  default     = "watsonx-studio"
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
  default     = "watsonx-runtime"
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
  default     = "private"

  validation {
    condition     = contains(["public", "public-and-private", "private"], var.watsonx_ai_runtime_service_endpoints)
    error_message = "The specified service endpoint is not valid. Supported options are public, public-and-private, or private."
  }
}

variable "watsonx_ai_new_project_members" {
  description = "The list of new members the owner of the Watsonx.ai project would like to add to the project. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-watsonx-ai/tree/main/solutions/standard/DA-watsonx_ai_new_project_members.md)"
  type = list(object({
    email  = string
    iam_id = string
    role   = string
    state  = optional(string, "ACTIVE")
    type   = optional(string, "user")
    })
  )
  default = []

  validation {
    condition = alltrue([
      for member in var.watsonx_ai_new_project_members : contains(["admin", "editor", "viewer"], member.role)
    ])
    error_message = "The specified new member role is not valid. Supported options are admin, editor, or viewer."
  }

  validation {
    condition = alltrue([
      for member in var.watsonx_ai_new_project_members : contains(["ACTIVE", "PENDING"], member.state)
    ])
    error_message = "The specified new member state is not valid. Supported options are `ACTIVE` or `PENDING`."
  }

  validation {
    condition = alltrue([
      for member in var.watsonx_ai_new_project_members : contains(["user", "group", "service", "profile"], member.type)
    ])
    error_message = "The specified new member type is not valid. Supported options are user, group, service, or profile."
  }

  validation {
    condition = alltrue([
      for member in var.watsonx_ai_new_project_members : member.type != "user" ? member.email == member.iam_id : true
    ])
    error_message = "The specified email and iam_id must be the same if the member type is not user."
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
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "Valid values for the `kms_endpoint_type_value` are `public` or `private`."
  }
}

variable "cos_key_ring_name" {
  type        = string
  default     = "cos-key-ring"
  description = "The name of the key ring to create for the Cloud Object Storage bucket key. If an existing key is used, this variable is not required. If the prefix input variable is passed, the name of the key ring is prefixed to the value in the `<prefix>-value` format."
}

variable "cos_key_name" {
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

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud_api_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Cloud Object Storage instance. Leave this input empty if the same account owns both instances."
  sensitive   = true
  default     = null
}

##############################################################################################################
# COS
##############################################################################################################

variable "existing_cos_instance_crn" {
  type        = string
  description = "The CRN of an existing Cloud Object Storage instance."
}

variable "skip_cos_kms_iam_auth_policy" {
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
  default     = "ai-project"
}

variable "project_description" {
  description = "A description of the watsonx.ai project that is created."
  type        = string
  default     = "The watsonx.ai project created by the deployable architecture - Cloud automation for watsonx.ai."
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

variable "mark_project_as_sensitive" {
  description = "Set to true to allow the watsonx.ai project to be created with 'Mark as sensitive' flag. It enforces access restriction and prevents data from being moved out of the project. "
  type        = bool
  default     = false
}
