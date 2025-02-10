variable "resource_group_id" {
  description = "The resource group ID where resources will be created."
  type        = string
}

variable "region" {
  description = "Region to be used for the watsonx resources creation."
  type        = string
}

variable "watsonx_ai_project_id" {
  description = "The ID of the watsonx project that is created."
  type        = string
}

variable "new_project_members" {
  description = "The list of new members the owner of the Watsonx.ai project would like to add to the project."
  type = list(object({
    email  = string
    iam_id = string
    role   = string
    })
  )
  default = []

  validation {
    condition = alltrue([
      for member in var.new_project_members : contains(["admin", "editor", "viewer"], member.role)
    ])
    error_message = "The specified new member role is not valid. Supported options are admin, editor, or viewer."
  }
}
