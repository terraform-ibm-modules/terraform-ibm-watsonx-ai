output "watsonx_project_id" {
  value       = local.watsonx_project_id
  description = "The ID watsonx project that's created."
}

output "watsonx_project_region" {
  value       = resource.restapi_object.configure_project.id
  description = "The region of watsonx project that's created."
}

output "watsonx_project_bucket_name" {
  value       = local.watsonx_project_data.entity.storage.properties.bucket_name
  description = "The name of the COS bucket created by the watsonx project."
}

output "watsonx_project_url" {
  value       = "${local.dataplatform_ui}/projects/${local.watsonx_project_id}?context=wx&sync_account_id=${local.account_id}"
  description = "The URL of the watsonx project that's created."
}

output "watsonx_machine_learning_account_id" {
  value       = local.account_id
  description = "The account id of the Watson Machine Learning instance."
}
