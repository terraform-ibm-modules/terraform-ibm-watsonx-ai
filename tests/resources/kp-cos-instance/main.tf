module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.6.0"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  key_ring_name = "cos-key-ring"
  key_name      = "cos-key"
}

module "kms" {
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "5.6.5"
  create_key_protect_instance = true
  key_protect_instance_name   = "${var.prefix}-kp"
  resource_group_id           = module.resource_group.resource_group_id
  region                      = var.region
  resource_tags               = var.resource_tags
  key_protect_allowed_network = var.key_protect_allowed_network
  keys = [
    {
      key_ring_name = (local.key_ring_name)
      keys = [
        {
          key_name = (local.key_name)
        }
      ]
    }
  ]
}

# Temporary workaround for issue https://github.ibm.com/GoldenEye/issues/issues/15533
module "cos_module" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "10.16.0"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  cos_instance_name = "${var.prefix}-cos"
  kms_key_crn       = module.kms.keys["${local.key_ring_name}.${local.key_name}"].crn
  create_cos_bucket = false
}
