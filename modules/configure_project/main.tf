resource "restapi_object" "configure_project" {
  path           = local.dataplatform_api
  read_path      = "${local.dataplatform_api}{id}"
  read_method    = "GET"
  create_path    = "${local.dataplatform_api}/transactional/v2/projects?verify_unique_name=true"
  create_method  = "POST"
  id_attribute   = "location"
  destroy_method = "DELETE"
  destroy_path   = "${local.dataplatform_api}/transactional{id}"
  data           = <<-EOT
                  {
                    "name": "${var.project_name}",
                    "generator": "terraform-ibm-watsonx-ai",
                    "type": "wx",
                    "storage": {
                      "type": "bmcos_object_storage",
                      "guid": "${var.cos_guid}",
                      "resource_crn": "${var.cos_crn}",
                      "delegated": ${var.watsonx_project_delegated}
                    },
                    "description": "${var.project_description}",
                    "public": true,
                    "tags": ${jsonencode(var.project_tags)},
                    "compute": [
                      {
                        "name": "${var.watsonx_ai_runtime_name}",
                        "guid": "${var.watsonx_ai_runtime_guid}",
                        "type": "machine_learning",
                        "crn": "${var.watsonx_ai_runtime_crn}"
                      }
                    ],
                    "settings": {
                      "access_restrictions": {
                        "data": ${var.mark_as_sensitive}
                      }
                    }
                  }
                  EOT
  update_method  = "PATCH"
  update_path    = "${local.dataplatform_api}{id}"
  update_data    = <<-EOT
                  {
                    "name": "${var.project_name}",
                    "type": "wx",
                    "description": "${var.project_description}",
                    "public": true,
                    "compute": [
                      {
                        "name": "${var.watsonx_ai_runtime_name}",
                        "guid": "${var.watsonx_ai_runtime_guid}",
                        "type": "machine_learning",
                        "crn": "${var.watsonx_ai_runtime_crn}",
                        "credentials": {}
                      }
                    ]
                  }
                  EOT
}

resource "time_sleep" "wait_5_seconds" {
  depends_on      = [restapi_object.configure_project]
  create_duration = "5s"
}

data "restapi_object" "get_project" {
  depends_on   = [resource.restapi_object.configure_project, resource.time_sleep.wait_5_seconds]
  path         = "${local.dataplatform_api}/v2/projects"
  query_string = "project_ids=${local.watsonx_project_id}"
  results_key  = "resources"
  search_key   = "metadata/guid"
  search_value = local.watsonx_project_id
  id_attribute = "metadata/guid"
}

locals {
  dataplatform_api_mapping = {
    "us-south" = "//api.dataplatform.cloud.ibm.com",
    "eu-gb"    = "//api.eu-gb.dataplatform.cloud.ibm.com",
    "eu-de"    = "//api.eu-de.dataplatform.cloud.ibm.com",
    "jp-tok"   = "//api.jp-tok.dataplatform.cloud.ibm.com",
    "au-syd"   = "//api.au-syd.dai.cloud.ibm.com",
    "ca-tor"   = "//api.ca-tor.dai.cloud.ibm.com"
  }
  dataplatform_api          = local.dataplatform_api_mapping[var.region]
  watsonx_project_id_object = restapi_object.configure_project.id
  watsonx_project_id        = regex("^.+/([a-f0-9\\-]+)$", local.watsonx_project_id_object)[0]
  watsonx_project_data      = jsondecode(data.restapi_object.get_project.api_response)
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
  version = "1.3.0"
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
    members = jsonencode(var.watsonx_ai_new_project_members)
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
