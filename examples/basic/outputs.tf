########################################################################################################################
# Outputs
########################################################################################################################

output "cos_instance_crn" {
  description = "CRN of the Cloud Object Storage instance"
  value       = module.cos.cos_instance_crn
}

output "watson_machine_learning_crn" {
  description = "CRN of the Watson Machine Learning instance"
  value       = module.watsonx_ai.watson_machine_learning_crn
}

output "watson_machine_learning_guid" {
  description = "GUID of the Watson Machine Learning instance"
  value       = module.watsonx_ai.watson_machine_learning_guid
}

output "watson_machine_learning_name" {
  description = "Name of the Watson Machine Learning instance"
  value       = module.watsonx_ai.watson_machine_learning_name
}

output "watson_machine_learning_plan_id" {
  description = "Plan ID of the Watson Machine Learning instance"
  value       = module.watsonx_ai.watson_machine_learning_plan_id
}

output "watson_machine_learning_dashboard_url" {
  description = "Dashboard URL of the Watson Machine Learning instance"
  value       = module.watsonx_ai.watson_machine_learning_dashboard_url
}

output "watson_studio_crn" {
  description = "CRN of the Watson Studio instance"
  value       = module.watsonx_ai.watson_studio_crn
}

output "watson_studio_guid" {
  description = "GUID of the Watson Studio instance"
  value       = module.watsonx_ai.watson_studio_guid
}

output "watson_studio_name" {
  description = "Name of the Watson Studio instance"
  value       = module.watsonx_ai.watson_studio_name
}

output "watson_studio_plan_id" {
  description = "Plan ID of the Watson Studio instance"
  value       = module.watsonx_ai.watson_studio_plan_id
}

output "watson_studio_dashboard_url" {
  description = "Dashboard URL of the Watson Studio instance"
  value       = module.watsonx_ai.watson_studio_dashboard_url
}

output "watsonx_project_id" {
  value       = module.watsonx_ai.watsonx_project_id
  description = "ID of the created project"
}

output "watsonx_project_url" {
  value       = module.watsonx_ai.watsonx_project_url
  description = "URL of the created project"
}
