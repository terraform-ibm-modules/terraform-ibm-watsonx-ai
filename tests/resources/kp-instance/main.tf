module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "kms" {
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.20.0"
  create_key_protect_instance = true
  key_protect_instance_name   = "${var.prefix}-kp"
  resource_group_id           = module.resource_group.resource_group_id
  region                      = var.region
  resource_tags               = var.resource_tags
  key_protect_allowed_network = var.key_protect_allowed_network
}
