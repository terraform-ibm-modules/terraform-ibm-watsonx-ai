# Temporary workaround for issue https://github.ibm.com/GoldenEye/issues/issues/15533

module "resource_group" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.2.1"
  resource_group_name = var.resource_group == null ? "${var.prefix}-resource-group" : null
}

module "cos_module" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "10.2.1"
  resource_group_id      = module.resource_group.resource_group_id
  cos_instance_name      = "${var.prefix}-cos"
  kms_encryption_enabled = false
  create_cos_bucket      = false
}
