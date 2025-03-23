terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "30a83aff-7a8b-4ca3-aa48-ab93268b5a8b"
}

resource "azurerm_resource_group" "rg" {
  location = "austriaeast"
  name     = "grupo_De_Almacenamiento"
}

resource "azurerm_storage_account" "storage_account" {
  name                          = "amintestplatzi123"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  public_network_access_enabled = false

  tags = {
    environment = "staging"
  }
}

output "cadena_conexion" {
  value     = azurerm_storage_account.storage_account.primary_connection_string
  sensitive = true
}