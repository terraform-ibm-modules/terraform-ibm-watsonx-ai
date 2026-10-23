locals {
  binaries_path = "/tmp"

  # Body sent on POST /transactional/v2/projects
  project_payload = jsonencode({
    name      = var.project_name
    generator = "terraform-ibm-watsonx-ai"
    type      = "wx"
    storage = {
      type         = "bmcos_object_storage"
      guid         = var.cos_guid
      resource_crn = var.cos_crn
      delegated    = var.watsonx_project_delegated
    }
    description = var.project_description
    public      = true
    tags        = var.project_tags
    compute = [
      {
        name = var.watsonx_ai_runtime_name
        guid = var.watsonx_ai_runtime_guid
        type = "machine_learning"
        crn  = var.watsonx_ai_runtime_crn
      }
    ]
    settings = {
      access_restrictions = {
        data = var.mark_as_sensitive
      }
    }
  })

  # Body sent on PATCH /v2/projects/{id}
  project_patch = jsonencode({
    name        = var.project_name
    type        = "wx"
    description = var.project_description
    public      = true
    compute = [
      {
        name        = var.watsonx_ai_runtime_name
        guid        = var.watsonx_ai_runtime_guid
        type        = "machine_learning"
        crn         = var.watsonx_ai_runtime_crn
        credentials = {}
      }
    ]
  })
}

# Creates the project over HTTP (POST) and deletes it on destroy (DELETE).
# The project is looked up by name, so renaming the project replaces it.
# The destroy provisioner cannot read provider data sources, so delete_project.sh
# authenticates with IBMCLOUD_API_KEY, IC_API_KEY or TF_VAR_ibmcloud_api_key.
resource "terraform_data" "project" {
  triggers_replace = {
    project_name = var.project_name
    region       = var.region
    script_hash  = filesha256("${path.module}/scripts/create_project.sh")
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/create_project.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      BINARIES_PATH   = local.binaries_path
      iam_token       = local.sensitive_tokendata
      region          = var.region
      project_name    = var.project_name
      project_payload = local.project_payload
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "${path.module}/scripts/delete_project.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      BINARIES_PATH = "/tmp"
      region        = self.triggers_replace.region
      project_name  = self.triggers_replace.project_name
    }
  }
}

# Applies the mutable settings over HTTP (PATCH) whenever they change, without
# replacing the project.
resource "terraform_data" "project_update" {
  depends_on = [terraform_data.project]
  triggers_replace = {
    project_name            = var.project_name
    region                  = var.region
    project_description     = var.project_description
    watsonx_ai_runtime_name = var.watsonx_ai_runtime_name
    watsonx_ai_runtime_guid = var.watsonx_ai_runtime_guid
    watsonx_ai_runtime_crn  = var.watsonx_ai_runtime_crn
    script_hash             = filesha256("${path.module}/scripts/update_project.sh")
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/update_project.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      BINARIES_PATH = local.binaries_path
      iam_token     = local.sensitive_tokendata
      region        = var.region
      project_name  = var.project_name
      project_patch = local.project_patch
    }
  }
}

# Drop the old restapi object from state without calling its destroy, so the
# project is not deleted. create_project.sh finds the existing project by name.
removed {
  from = restapi_object.configure_project
  lifecycle {
    destroy = false
  }
}

resource "time_sleep" "wait_5_seconds" {
  depends_on      = [terraform_data.project, terraform_data.project_update]
  create_duration = "5s"
}

# Reads the project back over HTTP (GET /v2/projects?name=...).
data "http" "project" {
  depends_on = [time_sleep.wait_5_seconds]
  url        = "${local.dataplatform_api}/v2/projects?name=${urlencode(var.project_name)}&limit=100"
  method     = "GET"
  request_headers = {
    Accept        = "application/json"
    Authorization = local.sensitive_tokendata
  }

  retry {
    attempts     = 3
    min_delay_ms = 2000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Reading the watsonx.ai project '${var.project_name}' returned HTTP ${self.status_code}."
    }
    postcondition {
      condition     = length([for p in try(jsondecode(self.response_body).resources, []) : p if p.entity.name == var.project_name]) == 1
      error_message = "Expected exactly one watsonx.ai project named '${var.project_name}'."
    }
  }
}

locals {
  dataplatform_api_mapping = {
    "us-south" = "https://api.dataplatform.cloud.ibm.com",
    "eu-gb"    = "https://api.eu-gb.dataplatform.cloud.ibm.com",
    "eu-de"    = "https://api.eu-de.dataplatform.cloud.ibm.com",
    "jp-tok"   = "https://api.jp-tok.dataplatform.cloud.ibm.com",
    "au-syd"   = "https://api.au-syd.dai.cloud.ibm.com",
    "ca-tor"   = "https://api.ca-tor.dai.cloud.ibm.com"
  }
  dataplatform_api     = local.dataplatform_api_mapping[var.region]
  watsonx_project_data = [for p in jsondecode(data.http.project.response_body).resources : p if p.entity.name == var.project_name][0]
  watsonx_project_id   = local.watsonx_project_data.metadata.guid
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
