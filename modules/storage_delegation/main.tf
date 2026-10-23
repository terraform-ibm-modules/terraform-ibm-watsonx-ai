module "kms_key_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.9.0"
  crn     = var.cos_kms_key_crn
}

locals {
  region = module.kms_key_crn_parser.region

  kms_service                 = module.kms_key_crn_parser.service_name
  kms_account_id              = module.kms_key_crn_parser.account_id
  kms_key_id                  = module.kms_key_crn_parser.resource
  target_resource_instance_id = module.kms_key_crn_parser.service_instance
}

resource "ibm_iam_authorization_policy" "cos_s2s_keyprotect" {
  count                       = !var.skip_iam_authorization_policy ? 1 : 0
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = var.cos_instance_guid
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.target_resource_instance_id
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
  roles = ["Reader"]
}

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.cos_s2s_keyprotect]
  # workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
  create_duration = "30s"
  # workaround for https://github.com/terraform-ibm-modules/terraform-ibm-cos/issues/672
  destroy_duration = "30s"
}

data "ibm_iam_auth_token" "tokendata" {}

locals {
  sensitive_tokendata = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
  binaries_path       = "/tmp"

  delegation_payload = jsonencode({
    cos_instance_id = var.cos_instance_guid
    kms_key_crn     = var.cos_kms_key_crn
    catalogs        = true
    projects        = true
  })
}

# Creates the storage delegation over HTTP (POST) and removes it on destroy (DELETE).
# The destroy provisioner cannot read provider data sources, so
# delete_storage_delegation.sh authenticates with IBMCLOUD_API_KEY, IC_API_KEY or
# TF_VAR_ibmcloud_api_key.
resource "terraform_data" "storage_delegation" {
  depends_on = [time_sleep.wait_for_authorization_policy]
  triggers_replace = {
    cos_instance_id = var.cos_instance_guid
    region          = local.region
    script_hash     = filesha256("${path.module}/scripts/create_storage_delegation.sh")
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/create_storage_delegation.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      BINARIES_PATH      = local.binaries_path
      iam_token          = local.sensitive_tokendata
      region             = local.region
      cos_instance_id    = var.cos_instance_guid
      delegation_payload = local.delegation_payload
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "${path.module}/scripts/delete_storage_delegation.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      BINARIES_PATH   = "/tmp"
      region          = self.triggers_replace.region
      cos_instance_id = self.triggers_replace.cos_instance_id
    }
  }
}

# Drop the old restapi object from state without calling its destroy, so the
# delegation is not removed. create_storage_delegation.sh finds the existing
# delegation by COS instance ID and patches it.
removed {
  from = restapi_object.storage_delegation
  lifecycle {
    destroy = false
  }
}

# Applies a changed KMS key over HTTP (PATCH) without removing the delegation.
resource "terraform_data" "storage_delegation_update" {
  depends_on = [terraform_data.storage_delegation]
  triggers_replace = {
    cos_instance_id = var.cos_instance_guid
    region          = local.region
    kms_key_crn     = var.cos_kms_key_crn
    script_hash     = filesha256("${path.module}/scripts/update_storage_delegation.sh")
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/update_storage_delegation.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      BINARIES_PATH      = local.binaries_path
      iam_token          = local.sensitive_tokendata
      region             = local.region
      cos_instance_id    = var.cos_instance_guid
      delegation_payload = local.delegation_payload
    }
  }
}
