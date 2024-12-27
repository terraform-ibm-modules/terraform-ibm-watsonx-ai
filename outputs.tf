########################################################################################################################
# Outputs
########################################################################################################################

output "watsonx_ai_runtime_crn" {
  description = "The CRN of the watsonx.ai Runtime instance."
  value       = local.watsonx_ai_runtime_crn
}

output "watsonx_ai_runtime_guid" {
  description = "The GUID of the watsonx.ai Runtime instance."
  value       = local.watsonx_ai_runtime_guid
}

output "watsonx_ai_runtime_name" {
  description = "The name of the watsonx.ai Runtime instance."
  value       = local.watsonx_ai_runtime_name
}

output "watsonx_ai_runtime_plan_id" {
  description = "The plan ID of the watsonx.ai Runtime instance."
  value       = local.watsonx_ai_runtime_plan_id
}

output "watsonx_ai_runtime_dashboard_url" {
  description = "The dashboard URL of the watsonx.ai Runtime instance."
  value       = local.watsonx_ai_runtime_dashboard_url
}

output "watsonx_ai_runtime_account_id" {
  value       = var.create_watsonx_ai_project ? module.configure_project[0].watsonx_ai_runtime_account_id : null
  description = "The account id of the watsonx.ai Runtime instance."
}

output "watsonx_ai_studio_crn" {
  description = "The CRN of the watsonx.ai Studio instance."
  value       = local.watsonx_ai_studio_crn
}

output "watsonx_ai_studio_guid" {
  description = "The GUID of the watsonx.ai Studio instance."
  value       = local.watsonx_ai_studio_guid
}

output "watsonx_ai_studio_name" {
  description = "The name of the watsonx.ai Studio instance."
  value       = local.watsonx_ai_studio_name
}

output "watsonx_ai_studio_plan_id" {
  description = "The plan ID of the watsonx.ai Studio instance."
  value       = local.watsonx_ai_studio_plan_id
}

output "watsonx_ai_studio_dashboard_url" {
  description = "The dashboard URL of the watsonx.ai Studio instance."
  value       = local.watsonx_ai_studio_dashboard_url
}

output "watsonx_project_id" {
  value       = var.create_watsonx_ai_project ? module.configure_project[0].watsonx_project_id : null
  description = "The ID of the watsonx project that is created."
}

output "watsonx_project_region" {
  value       = var.create_watsonx_ai_project ? module.configure_project[0].watsonx_project_region : null
  description = "The region of the watsonx project that is created."
}

output "watsonx_project_bucket_name" {
  value       = var.create_watsonx_ai_project ? module.configure_project[0].watsonx_project_bucket_name : null
  description = "The name of the COS bucket created for the watsonx project."
}

output "watsonx_project_url" {
  value       = var.create_watsonx_ai_project ? module.configure_project[0].watsonx_project_url : null
  description = "The URL of the watsonx project that is created."
}
