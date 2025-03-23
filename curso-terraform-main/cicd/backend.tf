terraform {
  backend "azurerm" {
    storage_account_name = "estadosterraformamin"
    container_name       = "githubactionstate"
    key                  = "estados.tfstate"
  }
}