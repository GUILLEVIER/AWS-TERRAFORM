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
resource "azurerm_resource_group" "resource_group" { 
    name = "azure-functions-test-rg" 
    location = "eastus2" 
} 
module "azure_function" { 
    source = "aminespinoza/azurefunctions/azurerm" 
    rg_name = azurerm_resource_group.resource_group.name 
    rg_location = azurerm_resource_group.resource_group.location 
    storage_account_name = "functionsapptest23" 
    app_service_name = "azure-functions-test-service-plan" 
    function_name = "curso-platzi-function" 
    storage_account_tier = "Premium" 
    storage_replication_type = "LRS" 
    app_service_plan_sku_tier = "Basic" 
    app_service_plan_sku_size = "B2" 
} 