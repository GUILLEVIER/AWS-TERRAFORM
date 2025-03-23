provider "azurerm" {
  features {}
  subscription_id = "30a83aff-7a8b-4ca3-aa48-ab93268b5a8b"
}

variable "rg_nombre" {
  type = string
}

locals {
  group_name = "amines${var.rg_nombre}"
}

resource "azurerm_resource_group" "rg" {
  location = "mexicocentral"
  name     = local.group_name
}