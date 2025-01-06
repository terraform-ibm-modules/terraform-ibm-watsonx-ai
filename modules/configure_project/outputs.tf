output "watsonx_ai_project_id" {
  value       = local.watsonx_project_id
  description = "The ID of the watsonx project that is created."
}

output "watsonx_ai_project_bucket_name" {
  value       = local.watsonx_project_data.entity.storage.properties.bucket_name
  description = "The name of the COS bucket created by the watsonx.ai project."
}

output "watsonx_ai_project_url" {
  value       = "${local.dataplatform_ui}/projects/${local.watsonx_project_id}?context=wx&sync_account_id=${local.account_id}"
  description = "The URL of the watsonx.ai project that is created."
}

output "watsonx_ai_runtime_account_id" {
  value       = local.account_id
  description = "The account id of the watsonx.ai Runtime instance."
}
