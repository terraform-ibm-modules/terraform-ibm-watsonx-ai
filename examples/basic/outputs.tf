########################################################################################################################
# Outputs
########################################################################################################################

output "cos_instance_crn" {
  description = "CRN of the Cloud Object Storage instance"
  value       = module.cos.cos_instance_crn
}

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

output "watsonx_project_id" {
  value       = module.watsonx_ai.watsonx_project_id
  description = "ID of the created project"
}

output "watsonx_project_url" {
  value       = module.watsonx_ai.watsonx_project_url
  description = "URL of the created project"
}
