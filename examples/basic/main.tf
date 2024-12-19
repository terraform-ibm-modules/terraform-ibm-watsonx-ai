##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm//modules/fscloud"
  version           = "8.15.1"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_plan          = "standard"
}

########################################################################################################################
# Example to create watsonx.ai project
########################################################################################################################

data "ibm_iam_auth_token" "restapi" {}


module "watsonx_saas" {
  source                    = "../.."
  ibmcloud_api_key          = var.ibmcloud_api_key
  prefix                    = var.prefix
  region                    = var.region
  resource_group_id         = module.resource_group.resource_group_id
  watsonx_project_name      = "${var.prefix}-project-basic"
  enable_cos_kms_encryption = false
  cos_instance_crn          = module.cos.cos_instance_crn
}
