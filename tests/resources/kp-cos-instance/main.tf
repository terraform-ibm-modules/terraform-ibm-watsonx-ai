module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.3.0"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "kms" {
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "5.1.24"
  create_key_protect_instance = true
  key_protect_instance_name   = "${var.prefix}-kp"
  resource_group_id           = module.resource_group.resource_group_id
  region                      = var.region
  resource_tags               = var.resource_tags
  key_protect_allowed_network = var.key_protect_allowed_network
}

# Temporary workaround for issue https://github.ibm.com/GoldenEye/issues/issues/15533
module "cos_module" {
  source                     = "terraform-ibm-modules/cos/ibm"
  version                    = "10.2.17"
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  cos_instance_name          = "${var.prefix}-cos"
  existing_kms_instance_guid = module.kms.kms_guid
  create_cos_bucket          = false
}
