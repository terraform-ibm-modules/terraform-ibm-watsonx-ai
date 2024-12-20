# ****************************************************************************************************
# Watsonx.ai Module
#
# It provisions Watsonx.ai Studio and Watsonx.ai Runtime, which are required for Watsonx.ai Project.
# Next, it configures watsonx user and the project using the provided Cloud Object Storage and
# KMS key for encryption.
# *****************************************************************************************************

# **********************
# Watsonx.ai Studio
# **********************

data "ibm_resource_instance" "existing_watson_studio_instance" {
  count      = var.existing_watson_studio_instance_crn != null ? 1 : 0
  identifier = var.existing_watson_studio_instance_crn
}

locals {
  watson_studio_crn           = var.existing_watson_studio_instance_crn != null ? data.ibm_resource_instance.existing_watson_studio_instance[0].crn : resource.ibm_resource_instance.watson_studio_instance[0].crn
  watson_studio_guid          = var.existing_watson_studio_instance_crn != null ? data.ibm_resource_instance.existing_watson_studio_instance[0].guid : resource.ibm_resource_instance.watson_studio_instance[0].guid
  watson_studio_name          = var.existing_watson_studio_instance_crn != null ? data.ibm_resource_instance.existing_watson_studio_instance[0].resource_name : resource.ibm_resource_instance.watson_studio_instance[0].resource_name
  watson_studio_plan_id       = var.existing_watson_studio_instance_crn != null ? null : resource.ibm_resource_instance.watson_studio_instance[0].resource_plan_id
  watson_studio_dashboard_url = var.existing_watson_studio_instance_crn != null ? null : resource.ibm_resource_instance.watson_studio_instance[0].dashboard_url
}

resource "ibm_resource_instance" "watson_studio_instance" {
  count             = var.existing_watson_studio_instance_crn != null ? 0 : 1
  name              = "${var.prefix}-watson-studio"
  service           = "data-science-experience"
  plan              = var.watson_studio_plan
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
# Watsonx.ai Runtime
# ****************************

locals {
  watson_machine_learning_crn           = var.existing_machine_learning_instance_crn != null ? data.ibm_resource_instance.existing_watson_machine_learning_instance[0].crn : resource.ibm_resource_instance.watson_machine_learning_instance[0].crn
  watson_machine_learning_guid          = var.existing_machine_learning_instance_crn != null ? data.ibm_resource_instance.existing_watson_machine_learning_instance[0].guid : resource.ibm_resource_instance.watson_machine_learning_instance[0].guid
  watson_machine_learning_name          = var.existing_machine_learning_instance_crn != null ? data.ibm_resource_instance.existing_watson_machine_learning_instance[0].resource_name : resource.ibm_resource_instance.watson_machine_learning_instance[0].resource_name
  watson_machine_learning_plan_id       = var.existing_machine_learning_instance_crn != null ? null : resource.ibm_resource_instance.watson_machine_learning_instance[0].resource_plan_id
  watson_machine_learning_dashboard_url = var.existing_machine_learning_instance_crn != null ? null : resource.ibm_resource_instance.watson_machine_learning_instance[0].dashboard_url
}

data "ibm_resource_instance" "existing_watson_machine_learning_instance" {
  count      = var.existing_machine_learning_instance_crn != null ? 1 : 0
  identifier = var.existing_machine_learning_instance_crn
}

resource "ibm_resource_instance" "watson_machine_learning_instance" {
  count             = var.existing_machine_learning_instance_crn != null ? 0 : 1
  name              = "${var.prefix}-watson-machine-learning"
  service           = "pm-20"
  plan              = var.watson_machine_learning_plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags

  parameters = {
    service-endpoints = var.watson_machine_learning_service_endpoints
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
# Configure watsonx project
# ****************************

locals {
  is_storage_delegated = var.enable_cos_kms_encryption ? true : false
  # tflint-ignore: terraform_unused_declarations
  validate_encryption_inputs = var.enable_cos_kms_encryption && (var.cos_kms_key_crn == null) ? tobool("A value must be passed for 'cos_kms_key_crn' when 'enable_cos_kms_encryption' is set to true") : true
}

module "cos_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.cos_instance_crn
}

module "storage_delegation" {
  source                        = "./modules/storage_delegation"
  count                         = var.enable_cos_kms_encryption ? 1 : 0
  cos_kms_key_crn               = var.cos_kms_key_crn
  cos_instance_guid             = module.cos_crn_parser.service_instance
  skip_iam_authorization_policy = var.skip_iam_authorization_policy
}

module "configure_project" {
  source                      = "./modules/configure_project"
  depends_on                  = [module.storage_delegation]
  count                       = var.enable_configure_project ? 1 : 0
  watsonx_project_name        = "${var.prefix}-${var.watsonx_project_name}"
  watsonx_project_description = var.watsonx_project_description
  watsonx_project_tags        = var.watsonx_project_tags
  watsonx_mark_as_sensitive   = var.watsonx_mark_as_sensitive
  machine_learning_guid       = local.watson_machine_learning_guid
  machine_learning_crn        = local.watson_machine_learning_crn
  machine_learning_name       = local.watson_machine_learning_name
  cos_guid                    = module.cos_crn_parser.service_instance
  cos_crn                     = var.cos_instance_crn
  watsonx_project_delegated   = local.is_storage_delegated
  region                      = var.region
}
