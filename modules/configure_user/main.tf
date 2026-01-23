data "ibm_iam_auth_token" "tokendata" {}

locals {
  sensitive_tokendata = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
  binaries_path       = "/tmp"

}

resource "terraform_data" "install_required_binaries" {
  count = var.install_required_binaries ? 1 : 0
  triggers_replace = {
    region            = var.region
    script_hash = filesha256("${path.module}/scripts/install-binaries.sh")
  }
  provisioner "local-exec" {
    command     = "${path.module}/scripts/install-binaries.sh ${local.binaries_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "terraform_data" "configure_user" {
  triggers_replace = {
    resource_group_id = var.resource_group_id
    region            = var.region
    script_hash       = filesha256("${path.module}/scripts/add_user.sh")
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

resource "terraform_data" "restrict_access" {
  triggers_replace = {
    region      = var.region
    script_hash = filesha256("${path.module}/scripts/enforce_account_restriction.sh")
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
