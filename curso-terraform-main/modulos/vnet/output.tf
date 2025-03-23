output "subnet_id" {
  value = azurerm_subnet.my_terraform_subnet.id
}

output "public_ip_address_id" {
  value = azurerm_public_ip.my_terraform_public_ip.id
}