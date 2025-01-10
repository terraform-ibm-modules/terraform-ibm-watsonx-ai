module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "key_protect_module" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "2.9.0"
  key_protect_name  = "${var.prefix}-kp"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  tags              = var.resource_tags
  allowed_network   = var.allowed_network
}

module "kms_root_key" {
  source          = "terraform-ibm-modules/kms-key/ibm"
  version         = "1.3.0"
  kms_instance_id = module.key_protect_module.key_protect_id
  key_name        = "${var.prefix}-root-key"
}