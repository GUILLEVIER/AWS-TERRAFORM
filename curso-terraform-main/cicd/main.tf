provider "azurerm" {
  features {}
  subscription_id = "30a83aff-7a8b-4ca3-aa48-ab93268b5a8b"
}

resource "azurerm_resource_group" "rg" {
  name     = "cicd-group"
  location = "eastus2"
}

resource "azurerm_storage_account" "storage" {
  name                     = "continousdeployment"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container_amin" {
  name                  = "platzimedellin"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "container"
}

resource "azurerm_storage_container" "container_oscar" {
  name                  = "oscarbarajas"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "container"
}
