locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}


#######################################################################################################################
# KMS Key
#######################################################################################################################

# parse KMS details from the existing KMS instance CRN
module "existing_kms_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_kms_instance_crn
}

locals {
  # fetch KMS region from existing_kms_instance_crn if KMS resources are required and existing_cos_kms_key_crn is not provided
  kms_region        = var.enable_cos_kms_encryption && var.existing_kms_instance_crn != null ? module.existing_kms_instance_crn_parser[0].region : null
  kms_key_ring_name = "${local.prefix}${var.cos_key_ring_name}"
  kms_key_name      = "${local.prefix}${var.cos_key_name}"
  create_kms_key    = (var.enable_cos_kms_encryption) ? (var.existing_cos_kms_key_crn == null ? (var.existing_kms_instance_crn != null ? true : false) : false) : false
}

module "kms" {
  count                       = local.create_kms_key ? 1 : 0 # no need to create any KMS resources if not passing an existing KMS CRN or existing KMS key CRN is provided
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "5.1.11"
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



########################################################################################################################
# Create watsonx.ai project with KMS encryption
########################################################################################################################

locals {
  cos_instance_crn  = var.existing_cos_instance_crn
  cos_kms_key_crn   = var.enable_cos_kms_encryption ? (var.existing_cos_kms_key_crn != null ? var.existing_cos_kms_key_crn : module.kms[0].keys[format("%s.%s", local.kms_key_ring_name, local.kms_key_name)].crn) : null
  cos_instance_guid = local.cos_instance_crn != null ? module.existing_cos_crn_parser[0].service_instance : null
  cos_account_id    = local.cos_instance_crn != null ? module.existing_cos_crn_parser[0].account_id : null
  kms_guid          = var.enable_cos_kms_encryption ? (length(module.existing_kms_key_crn_parser) > 0 ? module.existing_kms_key_crn_parser[0].service_instance : module.existing_kms_instance_crn_parser[0].service_instance) : null
  kms_account_id    = var.enable_cos_kms_encryption ? (length(module.existing_kms_key_crn_parser) > 0 ? module.existing_kms_key_crn_parser[0].account_id : module.existing_kms_instance_crn_parser[0].account_id) : null
  kms_service_name  = var.enable_cos_kms_encryption ? (length(module.existing_kms_key_crn_parser) > 0 ? module.existing_kms_key_crn_parser[0].service_name : module.existing_kms_instance_crn_parser[0].service_name) : null
}

locals {
  create_cos_kms_iam_auth_policy           = (var.enable_cos_kms_encryption && !var.skip_cos_kms_iam_auth_policy)
  create_cross_account_cos_kms_auth_policy = (local.create_cos_kms_iam_auth_policy && (var.ibmcloud_kms_api_key != null || (local.kms_account_id != null && local.cos_account_id != null && local.kms_account_id != local.cos_account_id)))
}

data "ibm_iam_auth_token" "restapi" {
}

module "watsonx_ai" {
  source            = "../.."
  region            = var.region
  resource_tags     = var.resource_tags
  resource_group_id = module.resource_group.resource_group_id

  existing_watsonx_ai_studio_instance_crn = var.existing_watsonx_ai_studio_instance_crn
  watsonx_ai_studio_plan                  = var.watsonx_ai_studio_plan
  watsonx_ai_studio_instance_name         = "${local.prefix}${var.watsonx_ai_studio_instance_name}"

  existing_watsonx_ai_runtime_instance_crn = var.existing_watsonx_ai_runtime_instance_crn
  watsonx_ai_runtime_plan                  = var.watsonx_ai_runtime_plan
  watsonx_ai_runtime_instance_name         = "${local.prefix}${var.watsonx_ai_runtime_instance_name}"
  watsonx_ai_runtime_service_endpoints     = var.watsonx_ai_runtime_service_endpoints
  watsonx_ai_new_project_members           = var.watsonx_ai_new_project_members

  create_watsonx_ai_project     = true
  project_name                  = "${local.prefix}${var.watsonx_ai_project_name}"
  project_description           = var.project_description
  project_tags                  = var.project_tags
  mark_as_sensitive             = var.mark_project_as_sensitive
  enable_cos_kms_encryption     = var.enable_cos_kms_encryption
  cos_instance_crn              = local.cos_instance_crn
  cos_kms_key_crn               = local.cos_kms_key_crn
  skip_iam_authorization_policy = local.create_cross_account_cos_kms_auth_policy || !local.create_cos_kms_iam_auth_policy
}

##############################################################################
# Cross-Account COS-KMS IAM Authorization Policy
##############################################################################
resource "ibm_iam_authorization_policy" "cos_kms_policy" {
  count                       = local.create_cross_account_cos_kms_auth_policy ? 1 : 0
  provider                    = ibm.kms
  source_service_account      = local.cos_account_id
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow COS ${local.cos_instance_guid} to read KMS key ${local.cos_kms_key_crn}"

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.kms_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.cos_kms_key_crn
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "time_sleep" "wait_for_cross_account_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.cos_kms_policy]
  count           = local.create_cross_account_cos_kms_auth_policy ? 1 : 0
  create_duration = "30s"
}

module "existing_cos_crn_parser" {
  count   = var.existing_cos_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_cos_instance_crn
}

module "existing_kms_key_crn_parser" {
  count   = var.enable_cos_kms_encryption && var.existing_cos_kms_key_crn != null && var.existing_kms_instance_crn != "" ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_cos_kms_key_crn
}

module "existing_kms_instance_crn_parser" {
  count   = var.enable_cos_kms_encryption && var.existing_kms_instance_crn != null && var.existing_kms_instance_crn != "" ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_kms_instance_crn
}
