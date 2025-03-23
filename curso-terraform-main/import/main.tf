provider "azurerm" {
  features {}
  subscription_id = "30a83aff-7a8b-4ca3-aa48-ab93268b5a8b"
}
import {
  to = azurerm_storage_account.mi_cuenta
  id = "/subscriptions/30a83aff-7a8b-4ca3-aa48-ab93268b5a8b/resourceGroups/logsGroup/providers/Microsoft.Storage/storageAccounts/logstorageaccount23"
}
resource "azurerm_storage_account" "mi_cuenta" {
  name                     = "logstorageaccount23"
  resource_group_name      = "logsGroup"
  location                 = "brazilsouth"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}