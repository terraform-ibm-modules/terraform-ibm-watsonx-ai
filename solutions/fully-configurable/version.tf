terraform {
  required_version = ">= 1.9.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.2.2"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.14.0, < 1.0.0"
    }
  }
}
