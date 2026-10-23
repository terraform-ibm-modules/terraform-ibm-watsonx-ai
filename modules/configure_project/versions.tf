terraform {
  required_version = ">= 1.9.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0, < 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.11.2"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.70.1, < 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2, <4.0.0"
    }
  }
}
