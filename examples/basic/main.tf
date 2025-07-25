##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm//modules/fscloud"
  version           = "10.1.9"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_plan          = "standard"
}

############################################################################################
# Create watsonx.ai project without KMS encryption
############################################################################################

data "ibm_iam_auth_token" "restapi" {}


module "watsonx_ai" {
  source                    = "../.."
  region                    = var.region
  resource_tags             = var.resource_tags
  resource_group_id         = module.resource_group.resource_group_id
  project_name              = "project-basic"
  watsonx_ai_studio_plan    = "professional-v1"
  watsonx_ai_runtime_plan   = "v2-standard"
  enable_cos_kms_encryption = false
  cos_instance_crn          = module.cos.cos_instance_crn
}
