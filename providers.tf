#declare providers
terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

#declare service principal specs for authentication
provider "azurerm" {
  features {}
   client_id       = "0bfc128c-440a-48b6-afea-33bcd398736e"
   client_secret   = var.clientsec
   tenant_id       = "2097be21-35c2-4b8f-a1a7-cfc499234b86"
   subscription_id = "2d6eff3c-234a-44e7-b2a2-95c937c383c4"
}