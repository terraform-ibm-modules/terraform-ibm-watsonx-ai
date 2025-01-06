########################################################################################################################
# Outputs
########################################################################################################################

output "watsonx_ai_runtime_crn" {
  description = "CRN of the watsonx.ai Runtime instance"
  value       = module.watsonx_ai.watsonx_ai_runtime_crn
}

output "watsonx_ai_runtime_guid" {
  description = "GUID of the watsonx.ai Runtime instance"
  value       = module.watsonx_ai.watsonx_ai_runtime_guid
}

output "watsonx_ai_runtime_name" {
  description = "Name of the watsonx.ai Runtime instance"
  value       = module.watsonx_ai.watsonx_ai_runtime_name
}

output "watsonx_ai_runtime_plan_id" {
  description = "Plan ID of the watsonx.ai Runtime instance"
  value       = module.watsonx_ai.watsonx_ai_runtime_plan_id
}

output "watsonx_ai_runtime_dashboard_url" {
  description = "Dashboard URL of the watsonx.ai Runtime instance"
  value       = module.watsonx_ai.watsonx_ai_runtime_dashboard_url
}

output "watsonx_ai_studio_crn" {
  description = "CRN of the watsonx.ai Studio instance"
  value       = module.watsonx_ai.watsonx_ai_studio_crn
}

output "watsonx_ai_studio_guid" {
  description = "GUID of the watsonx.ai Studio instance"
  value       = module.watsonx_ai.watsonx_ai_studio_guid
}

output "watsonx_ai_studio_name" {
  description = "Name of the watsonx.ai Studio instance"
  value       = module.watsonx_ai.watsonx_ai_studio_name
}

output "watsonx_ai_studio_plan_id" {
  description = "Plan ID of the watsonx.ai Studio instance"
  value       = module.watsonx_ai.watsonx_ai_studio_plan_id
}

output "watsonx_ai_studio_dashboard_url" {
  description = "Dashboard URL of the watsonx.ai Studio instance"
  value       = module.watsonx_ai.watsonx_ai_studio_dashboard_url
}

output "watsonx_ai_project_id" {
  value       = module.watsonx_ai.watsonx_ai_project_id
  description = "ID of the created watsonx.ai project"
}

output "watsonx_ai_project_url" {
  value       = module.watsonx_ai.watsonx_ai_project_url
  description = "URL of the created watsonx.ai project"
}

output "watsonx_ai_project_bucket_name" {
  value       = module.watsonx_ai.watsonx_ai_project_bucket_name
  description = "The name of the COS bucket created for the watsonx.ai project."
}

output "cos_kms_key_crn" {
  description = "CRN of the KMS Key"
  value       = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
}
