resource "ibm_watsonx_project" "this" {
  region            = var.region
  name              = var.project_name
  description       = var.project_description
  tags              = var.project_tags
  cos_instance_id   = var.cos_guid
  cos_crn           = var.cos_crn
  storage_delegated = var.watsonx_project_delegated
  mark_as_sensitive = var.mark_as_sensitive
  runtime_name      = var.watsonx_ai_runtime_name
  runtime_guid      = var.watsonx_ai_runtime_guid
  runtime_crn       = var.watsonx_ai_runtime_crn
}

# Drop the old restapi object from state without calling its destroy, so the
# project is not deleted. Existing projects must be imported into
# ibm_watsonx_project before the first apply; see the module README.
removed {
  from = restapi_object.configure_project
  lifecycle {
    destroy = false
  }
}

resource "time_sleep" "wait_5_seconds" {
  depends_on      = [ibm_watsonx_project.this]
  create_duration = "5s"
}

data "ibm_watsonx_project" "this" {
  depends_on = [time_sleep.wait_5_seconds]
  region     = var.region
  project_id = ibm_watsonx_project.this.id
}

locals {
  watsonx_project_id   = ibm_watsonx_project.this.id
  watsonx_project_data = jsondecode(data.ibm_watsonx_project.this.project_json)
  dataplatform_ui_mapping = {
    "us-south" = "https://dataplatform.cloud.ibm.com",
    "eu-gb"    = "https://eu-gb.dataplatform.cloud.ibm.com",
    "eu-de"    = "https://eu-de.dataplatform.cloud.ibm.com",
    "jp-tok"   = "https://jp-tok.dataplatform.cloud.ibm.com",
    "au-syd"   = "https://au-syd.dai.cloud.ibm.com",
    "ca-tor"   = "https://ca-tor.dai.cloud.ibm.com"
  }
  dataplatform_ui = local.dataplatform_ui_mapping[var.region]

  #following are required for output
  account_id = module.watsonx_ai_runtime_crn_parser.account_id
}

module "watsonx_ai_runtime_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.9.0"
  crn     = var.watsonx_ai_runtime_crn
}

data "ibm_iam_auth_token" "tokendata" {}

locals {
  sensitive_tokendata = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
}

resource "null_resource" "add_collaborators_to_project" {
  for_each   = { for member in var.watsonx_ai_new_project_members : member.email => member }
  depends_on = [data.ibm_iam_auth_token.tokendata]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = "${path.module}/scripts/add_collaborators_to_project.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      iam_token  = local.sensitive_tokendata
      region     = var.region
      project_id = local.watsonx_project_id
      user_name  = each.value.email
      iam_id     = each.value.iam_id
      role       = each.value.role
      state      = each.value.state
      type       = each.value.type
    }
  }
}
