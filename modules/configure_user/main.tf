data "ibm_iam_auth_token" "tokendata" {}

locals {
  sensitive_tokendata = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
}

resource "null_resource" "configure_user" {
  depends_on = [data.ibm_iam_auth_token.tokendata]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/add_user.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      iam_token         = local.sensitive_tokendata
      resource_group_id = var.resource_group_id
      region            = var.region
    }
  }
}

resource "null_resource" "restrict_access" {
  depends_on = [data.ibm_iam_auth_token.tokendata]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/enforce_account_restriction.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      iam_token = local.sensitive_tokendata
      region    = var.region
    }
  }
}

resource "null_resource" "add_to_project" {
  for_each   = { for member in var.new_project_members : member.email => member }
  depends_on = [data.ibm_iam_auth_token.tokendata]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/add_user_to_project.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      iam_token  = local.sensitive_tokendata
      region     = var.region
      project_id = var.watsonx_ai_project_id
      user_name  = each.value.email
      iam_id     = each.value.iam_id
      role       = each.value.role
    }
  }
}
