terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.0"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "your_resource_group_name"
  #   storage_account_name = "your_storage_account_name"
  #   container_name       = "your_storage_container_name"
  #   key                  = "stateFile/tf.state"
  # }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "null" {

}
