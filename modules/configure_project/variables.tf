############################################################
# watsonx.ai variables
############################################################

variable "project_name" {
  description = "The name of the watsonx.ai project, which serves as a unique identifier for the project."
  type        = string
}

variable "project_description" {
  description = "This provides a short summary of the watsonx.ai project, explaining its purpose or goals briefly."
  type        = string
}

variable "project_tags" {
  description = "A list of tags associated with the watsonx.ai project. Each tag consists of a single string containing up to 255 characters. These tags can include spaces, letters, numbers, underscores, dashes, as well as the symbols # and @."
  type        = list(string)
}

variable "watsonx_project_delegated" {
  description = "Set to true if the COS instance is delegated by the account admin."
  type        = bool
  default     = false
}

variable "region" {
  description = "The location that is used with the IBM Cloud Terraform IBM provider. It is also used during resource creation."
  type        = string
}

variable "mark_as_sensitive" {
  description = "Set to true to allow the watsonx.ai project to be created with 'Mark as sensitive' flag."
  type        = bool
  default     = false
}

variable "watsonx_ai_new_project_members" {
  description = "The list of new members the owner of the Watsonx.ai project would like to add to the project."
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
}

############################################################
# COS variables
############################################################

variable "cos_guid" {
  description = "The globally unique identifier of the Cloud Object Storage instance."
  type        = string
}

variable "cos_crn" {
  description = "This is used to identify the unique Cloud Object Storage instance CRN."
  type        = string
}

############################################################
# watsonx.ai Runtime variables
############################################################

variable "watsonx_ai_runtime_guid" {
  description = "This GUID is the globally unique identifier for the watsonx.ai Runtime instance."
  type        = string
}

variable "watsonx_ai_runtime_crn" {
  description = "This is used to identify the unique watsonx.ai Runtime instance CRN."
  type        = string
}

variable "watsonx_ai_runtime_name" {
  description = "The name of the watsonx.ai Runtime instance, which is a unique identifier for the instance."
  type        = string
}
