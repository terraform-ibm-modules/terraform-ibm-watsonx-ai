########################################################################################################################
# Outputs
########################################################################################################################

output "watson_machine_learning_crn" {
  description = "The CRN of the Watson Machine Learning instance."
  value       = local.watson_machine_learning_crn
}

output "watson_machine_learning_guid" {
  description = "The GUID of the Watson Machine Learning instance."
  value       = local.watson_machine_learning_guid
}

output "watson_machine_learning_name" {
  description = "The name of the Watson Machine Learning instance."
  value       = local.watson_machine_learning_name
}

output "watson_machine_learning_plan_id" {
  description = "The plan ID of the Watson Machine Learning instance."
  value       = local.watson_machine_learning_plan_id
}

output "watson_machine_learning_dashboard_url" {
  description = "The dashboard URL of the Watson Machine Learning instance."
  value       = local.watson_machine_learning_dashboard_url
}

output "watsonx_machine_learning_account_id" {
  value       = var.enable_configure_project ? module.configure_project[0].watsonx_machine_learning_account_id : null
  description = "The account id of the Watson Machine Learning instance."
}

output "watson_studio_crn" {
  description = "The CRN of the Watson Studio instance."
  value       = local.watson_studio_crn
}

output "watson_studio_guid" {
  description = "The GUID of the Watson Studio instance."
  value       = local.watson_studio_guid
}

output "watson_studio_name" {
  description = "The name of the Watson Studio instance."
  value       = local.watson_studio_name
}

output "watson_studio_plan_id" {
  description = "The plan ID of the Watson Studio instance."
  value       = local.watson_studio_plan_id
}

output "watson_studio_dashboard_url" {
  description = "The dashboard URL of the Watson Studio instance."
  value       = local.watson_studio_dashboard_url
}

output "watsonx_project_id" {
  value       = var.enable_configure_project ? module.configure_project[0].watsonx_project_id : null
  description = "The ID watsonx project that's created."
}

output "watsonx_project_region" {
  value       = var.enable_configure_project ? module.configure_project[0].watsonx_project_region : null
  description = "The region of watsonx project that's created."
}

output "watsonx_project_bucket_name" {
  value       = var.enable_configure_project ? module.configure_project[0].watsonx_project_bucket_name : null
  description = "The name of the COS bucket created by the watsonx project."
}

output "watsonx_project_url" {
  value       = var.enable_configure_project ? module.configure_project[0].watsonx_project_url : null
  description = "The URL of the watsonx project that's created."
}
