locals {
  prefix = var.prefix != null ? (var.prefix != "" ? var.prefix : null) : null
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.use_existing_resource_group == false ? try("${local.prefix}-${var.resource_group_name}", var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}


#######################################################################################################################
# KMS Key
#######################################################################################################################

# parse KMS details from the existing KMS instance CRN
module "existing_kms_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_instance_crn
}

locals {
  # fetch KMS region from existing_kms_instance_crn if KMS resources are required and existing_cos_kms_key_crn is not provided
  kms_region = var.existing_cos_kms_key_crn == null && var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].region : null

  kms_key_ring_name = try("${var.prefix}-${var.kms_key_ring_name}", var.kms_key_ring_name)
  kms_key_name      = try("${var.prefix}-${var.kms_key_name}", var.kms_key_name)
}

module "kms" {
  count                       = (var.existing_cos_kms_key_crn == null && var.existing_kms_instance_crn != null) ? 1 : 0 # no need to create any KMS resources if passing an existing key
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.19.5"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name         = local.kms_key_ring_name
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = local.kms_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}

#######################################################################################################################
# COS
#######################################################################################################################

module "cos_instance" {
  count               = var.existing_cos_instance_crn == null ? 1 : 0 # no need to call COS module if consumer is using existing COS instance
  source              = "terraform-ibm-modules/cos/ibm//modules/fscloud"
  version             = "8.19.2"
  resource_group_id   = module.resource_group.resource_group_id
  create_cos_instance = true
  cos_instance_name   = try("${local.prefix}-${var.cos_instance_name}", var.cos_instance_name)
  cos_tags            = var.cos_instance_tags
  access_tags         = var.cos_instance_access_tags
  cos_plan            = var.cos_plan
}


########################################################################################################################
# Create watsonx.ai project with KMS encryption
########################################################################################################################

locals {
  cos_instance_crn = var.existing_cos_instance_crn == null ? module.cos_instance[0].cos_instance_crn : var.existing_cos_instance_crn
  cos_kms_key_crn  = var.enable_cos_kms_encryption ? (var.existing_cos_kms_key_crn != null ? var.existing_cos_kms_key_crn : module.kms[0].keys[format("%s.%s", local.kms_key_ring_name, local.kms_key_name)].crn) : null
}


data "ibm_iam_auth_token" "restapi" {
}

module "watsonx_ai" {
  source            = "../.."
  prefix            = local.prefix
  region            = var.region
  resource_tags     = var.resource_tags
  resource_group_id = module.resource_group.resource_group_id

  existing_watsonx_ai_studio_instance_crn = var.existing_watsonx_ai_studio_instance_crn
  watsonx_ai_studio_plan                  = var.watsonx_ai_studio_plan
  watsonx_ai_studio_instance_name         = var.watsonx_ai_studio_instance_name

  existing_watsonx_ai_runtime_instance_crn = var.existing_watsonx_ai_runtime_instance_crn
  watsonx_ai_runtime_plan                  = var.watsonx_ai_runtime_plan
  watsonx_ai_runtime_instance_name         = var.watsonx_ai_runtime_instance_name
  watsonx_ai_runtime_service_endpoints     = var.watsonx_ai_runtime_service_endpoints
  watsonx_ai_new_project_members           = var.watsonx_ai_new_project_members

  create_watsonx_ai_project     = true
  project_name                  = var.watsonx_ai_project_name
  project_description           = var.project_description
  project_tags                  = var.project_tags
  mark_as_sensitive             = var.mark_as_sensitive
  enable_cos_kms_encryption     = var.enable_cos_kms_encryption
  cos_instance_crn              = local.cos_instance_crn
  cos_kms_key_crn               = local.cos_kms_key_crn
  skip_iam_authorization_policy = var.skip_cos_kms_authorization_policy
}
