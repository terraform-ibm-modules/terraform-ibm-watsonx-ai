data "ibm_iam_auth_token" "tokendata" {}

locals {
  sensitive_tokendata = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
  binaries_path       = "/tmp"
}

resource "terraform_data" "install_required_binaries" {
  count = var.install_required_binaries ? 1 : 0
  triggers_replace = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = "${path.module}/scripts/install-binaries.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}


resource "null_resource" "configure_user" {
  depends_on = [terraform_data.install_required_binaries, data.ibm_iam_auth_token.tokendata]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = "${path.module}/scripts/add_user.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      iam_token         = local.sensitive_tokendata
      resource_group_id = var.resource_group_id
      region            = var.region
    }
  }
}

resource "null_resource" "restrict_access" {
  depends_on = [terraform_data.install_required_binaries, data.ibm_iam_auth_token.tokendata]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/enforce_account_restriction.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      iam_token = local.sensitive_tokendata
      region    = var.region
    }
  }
}
