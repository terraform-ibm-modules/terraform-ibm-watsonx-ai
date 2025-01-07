##############################################################################
# Provider config
##############################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "restapi" {
  uri                  = "https:"
  write_returns_object = true
  debug                = true
  headers = {
    Authorization = data.ibm_iam_auth_token.restapi.iam_access_token
    Content-Type  = "application/json"
  }
}
