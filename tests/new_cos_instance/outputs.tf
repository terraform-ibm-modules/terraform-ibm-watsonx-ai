output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name"
}

output "cos_crn" {
  value       = module.cos_module.cos_instance_crn
  description = "CRN of Cloud Object Storage instance"
}
