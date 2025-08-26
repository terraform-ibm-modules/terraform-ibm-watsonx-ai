output "key_protect_crn" {
  value       = module.kms.key_protect_crn
  description = "CRN of the Key Protect instance"
}

output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name"
}
