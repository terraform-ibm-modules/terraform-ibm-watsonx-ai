# ****************************************************************************************************
# watsonx.ai Module
# *****************************************************************************************************

# **********************
# watsonx.ai Studio
# **********************

data "ibm_resource_instance" "existing_watsonx_ai_studio_instance" {
  count      = var.existing_watsonx_ai_studio_instance_crn != null ? 1 : 0
  identifier = var.existing_watsonx_ai_studio_instance_crn
}

locals {
  watsonx_ai_studio_crn           = var.existing_watsonx_ai_studio_instance_crn != null ? data.ibm_resource_instance.existing_watsonx_ai_studio_instance[0].crn : resource.ibm_resource_instance.watsonx_ai_studio_instance[0].crn
  watsonx_ai_studio_guid          = var.existing_watsonx_ai_studio_instance_crn != null ? data.ibm_resource_instance.existing_watsonx_ai_studio_instance[0].guid : resource.ibm_resource_instance.watsonx_ai_studio_instance[0].guid
  watsonx_ai_studio_name          = var.existing_watsonx_ai_studio_instance_crn != null ? data.ibm_resource_instance.existing_watsonx_ai_studio_instance[0].resource_name : resource.ibm_resource_instance.watsonx_ai_studio_instance[0].resource_name
  watsonx_ai_studio_plan_id       = var.existing_watsonx_ai_studio_instance_crn != null ? null : resource.ibm_resource_instance.watsonx_ai_studio_instance[0].resource_plan_id
  watsonx_ai_studio_dashboard_url = var.existing_watsonx_ai_studio_instance_crn != null ? null : resource.ibm_resource_instance.watsonx_ai_studio_instance[0].dashboard_url
}

resource "ibm_resource_instance" "watsonx_ai_studio_instance" {
  count             = var.existing_watsonx_ai_studio_instance_crn != null ? 0 : 1
  name              = var.watsonx_ai_studio_instance_name
  service           = "data-science-experience"
  plan              = var.watsonx_ai_studio_plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# ****************************
# watsonx.ai Runtime
# ****************************

locals {
  watsonx_ai_runtime_crn           = var.existing_watsonx_ai_runtime_instance_crn != null ? data.ibm_resource_instance.existing_watsonx_ai_runtime_instance[0].crn : resource.ibm_resource_instance.watsonx_ai_runtime_instance[0].crn
  watsonx_ai_runtime_guid          = var.existing_watsonx_ai_runtime_instance_crn != null ? data.ibm_resource_instance.existing_watsonx_ai_runtime_instance[0].guid : resource.ibm_resource_instance.watsonx_ai_runtime_instance[0].guid
  watsonx_ai_runtime_name          = var.existing_watsonx_ai_runtime_instance_crn != null ? data.ibm_resource_instance.existing_watsonx_ai_runtime_instance[0].resource_name : resource.ibm_resource_instance.watsonx_ai_runtime_instance[0].resource_name
  watsonx_ai_runtime_plan_id       = var.existing_watsonx_ai_runtime_instance_crn != null ? null : resource.ibm_resource_instance.watsonx_ai_runtime_instance[0].resource_plan_id
  watsonx_ai_runtime_dashboard_url = var.existing_watsonx_ai_runtime_instance_crn != null ? null : resource.ibm_resource_instance.watsonx_ai_runtime_instance[0].dashboard_url
}

data "ibm_resource_instance" "existing_watsonx_ai_runtime_instance" {
  count      = var.existing_watsonx_ai_runtime_instance_crn != null ? 1 : 0
  identifier = var.existing_watsonx_ai_runtime_instance_crn
}

resource "ibm_resource_instance" "watsonx_ai_runtime_instance" {
  count             = var.existing_watsonx_ai_runtime_instance_crn != null ? 0 : 1
  name              = var.watsonx_ai_runtime_instance_name
  service           = "pm-20"
  plan              = var.watsonx_ai_runtime_plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags

  parameters = {
    service-endpoints = var.watsonx_ai_runtime_service_endpoints
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# ****************************
# Configure user
# ****************************

module "configure_user" {
  source            = "./modules/configure_user"
  resource_group_id = var.resource_group_id
  region            = var.region
}

# ****************************
# Configure watsonx.ai project
# ****************************

locals {
  is_storage_delegated = var.enable_cos_kms_encryption ? true : false
  # fetch KMS region from existing_cos_kms_key_crn
  kms_region = var.cos_kms_key_crn != null ? module.cos_kms_key_crn_parser[0].region : null
}

module "cos_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.0"
  crn     = var.cos_instance_crn
}

module "cos_kms_key_crn_parser" {
  count   = var.enable_cos_kms_encryption ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.0"
  crn     = var.cos_kms_key_crn
}

locals {
  cos_guid = module.cos_crn_parser.service_instance
}

module "storage_delegation" {
  source                        = "./modules/storage_delegation"
  count                         = var.enable_cos_kms_encryption ? 1 : 0
  cos_kms_key_crn               = var.cos_kms_key_crn
  cos_instance_guid             = module.cos_crn_parser.service_instance
  skip_iam_authorization_policy = var.skip_iam_authorization_policy
}

module "configure_project" {
  source                         = "./modules/configure_project"
  depends_on                     = [module.storage_delegation]
  count                          = var.create_watsonx_ai_project ? 1 : 0
  project_name                   = var.project_name
  project_description            = var.project_description
  project_tags                   = var.project_tags
  mark_as_sensitive              = var.mark_as_sensitive
  watsonx_ai_runtime_guid        = local.watsonx_ai_runtime_guid
  watsonx_ai_runtime_crn         = local.watsonx_ai_runtime_crn
  watsonx_ai_runtime_name        = local.watsonx_ai_runtime_name
  cos_guid                       = local.cos_guid
  cos_crn                        = var.cos_instance_crn
  watsonx_project_delegated      = local.is_storage_delegated
  region                         = var.region
  watsonx_ai_new_project_members = var.watsonx_ai_new_project_members
}
