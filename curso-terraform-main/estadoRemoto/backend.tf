terraform {
  backend "azurerm" {
    storage_account_name = "estadosterraformamin"
    container_name       = "states"
    key                  = "estados.tfstate"
  }
}