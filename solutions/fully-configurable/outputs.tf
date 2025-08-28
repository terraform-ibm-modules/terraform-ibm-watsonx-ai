########################################################################################################################
# Outputs
########################################################################################################################

# watsonx.ai Runtime
output "watsonx_ai_runtime_crn" {
  description = "The CRN of the watsonx.ai Runtime instance."
  value       = module.watsonx_ai.watsonx_ai_runtime_crn
}

output "watsonx_ai_runtime_guid" {
  description = "The GUID of the watsonx.ai Runtime instance."
  value       = module.watsonx_ai.watsonx_ai_runtime_guid
}

output "watsonx_ai_runtime_name" {
  description = "The name of the watsonx.ai Runtime instance."
  value       = module.watsonx_ai.watsonx_ai_runtime_name
}

output "watsonx_ai_runtime_plan_id" {
  description = "The plan ID of the watsonx.ai Runtime instance."
  value       = module.watsonx_ai.watsonx_ai_runtime_plan_id
}

output "watsonx_ai_runtime_dashboard_url" {
  description = "The dashboard URL of the watsonx.ai Runtime instance."
  value       = module.watsonx_ai.watsonx_ai_runtime_dashboard_url
}

output "watsonx_ai_runtime_account_id" {
  value       = module.watsonx_ai.watsonx_ai_runtime_account_id
  description = "The account id of the watsonx.ai Runtime instance."
}

# watsonx.ai Studio
output "watsonx_ai_studio_crn" {
  description = "The CRN of the watsonx.ai Studio instance."
  value       = module.watsonx_ai.watsonx_ai_studio_crn
}

output "watsonx_ai_studio_guid" {
  description = "The GUID of the watsonx.ai Studio instance."
  value       = module.watsonx_ai.watsonx_ai_studio_guid
}

output "watsonx_ai_studio_name" {
  description = "The name of the watsonx.ai Studio instance."
  value       = module.watsonx_ai.watsonx_ai_studio_name
}

output "watsonx_ai_studio_plan_id" {
  description = "The plan ID of the watsonx.ai Studio instance."
  value       = module.watsonx_ai.watsonx_ai_studio_plan_id
}

output "watsonx_ai_studio_dashboard_url" {
  description = "The dashboard URL of the watsonx.ai Studio instance."
  value       = module.watsonx_ai.watsonx_ai_studio_dashboard_url
}

# watsonx.ai Project
output "watsonx_ai_project_id" {
  value       = module.watsonx_ai.watsonx_ai_project_id
  description = "The ID of the watsonx.ai project that is created."
}

output "watsonx_ai_project_bucket_name" {
  value       = module.watsonx_ai.watsonx_ai_project_bucket_name
  description = "The name of the COS bucket created for the watsonx.ai project."
}

output "watsonx_ai_project_url" {
  value       = module.watsonx_ai.watsonx_ai_project_url
  description = "The URL of the watsonx.ai project that is created."
}

output "cos_kms_key_crn" {
  description = "The CRN of the key management service (Key Protect) key used to encrypt the Cloud Object Storage bucket that the solution creates."
  value       = local.cos_kms_key_crn
}
