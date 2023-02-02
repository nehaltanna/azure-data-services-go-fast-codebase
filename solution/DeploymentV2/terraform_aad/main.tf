# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.20.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.28.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.3.2"
    }
  }
}

provider "azuread" {
  tenant_id = "a3b93842-8e64-4b66-97f0-f926ab0c02a8"
}


resource "random_id" "rg_deployment_unique" {
  byte_length = 4
}
