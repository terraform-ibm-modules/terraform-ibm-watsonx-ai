terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.66.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}