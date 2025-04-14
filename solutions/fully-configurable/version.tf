terraform {
  required_version = ">= 1.9.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.77.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
  }
}
