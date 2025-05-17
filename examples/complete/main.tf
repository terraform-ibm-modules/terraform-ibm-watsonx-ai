##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm//modules/fscloud"
  version           = "8.21.24"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_plan          = "standard"
  cos_tags          = var.resource_tags
}

##############################################################################
# Key Protect All Inclusive
##############################################################################

locals {
  key_ring_name = "${var.prefix}-keyring"
  key_name      = "${var.prefix}-key"
}

module "key_protect_all_inclusive" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.1.4"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  key_protect_instance_name = "${var.prefix}-kp"
  resource_tags             = var.resource_tags
  keys = [
    {
      key_ring_name = local.key_ring_name
      keys = [
        {
          key_name     = local.key_name
          force_delete = true
        }
      ]
    }
  ]
}

########################################################################################################################
# Create watsonx.ai project with KMS encryption
########################################################################################################################

data "ibm_iam_auth_token" "restapi" {
}


module "watsonx_ai" {
  source                    = "../.."
  prefix                    = var.prefix
  region                    = var.region
  resource_tags             = var.resource_tags
  resource_group_id         = module.resource_group.resource_group_id
  watsonx_ai_studio_plan    = "professional-v1"
  watsonx_ai_runtime_plan   = "v2-professional"
  project_name              = "${var.prefix}-project-complete"
  enable_cos_kms_encryption = true
  cos_instance_crn          = module.cos.cos_instance_crn
  cos_kms_key_crn           = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
}
