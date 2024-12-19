############################################################
# COS variables
############################################################

variable "cos_instance_guid" {
  description = "The globally unique identifier of the Cloud Object Storage instance."
  type        = string
  default     = null
}

############################################################
# KMS variables
############################################################

variable "cos_kms_key_crn" {
  description = "Key Protect key CRN used to encrypt the COS buckets used by the watsonx projects."
  type        = string
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy."
  default     = false
}