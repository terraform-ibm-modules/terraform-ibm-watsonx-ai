terraform {
  required_version = ">= 1.9.0"
  required_providers {
    restapi = {
      source                = "Mastercard/restapi"
      version               = ">= 1.19.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.11.2"
    }
  }
}
