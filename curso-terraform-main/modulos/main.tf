resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.resource_group_name
}

module "vnet" {
  source              = "./vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "nsg" {
  source              = "./nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "vm" {
  source                    = "./vm"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  vm_username               = var.vm_username
  vm_password               = var.vm_password
  public_ip_address_id      = module.vnet.public_ip_address_id
  subnet_id                 = module.vnet.subnet_id
  network_security_group_id = module.nsg.network_security_group_id
}

