
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.19.1"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.70.1, < 2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.0"
    }
  }
}
