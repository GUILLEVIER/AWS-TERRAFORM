output "cadena_conexion" {
  value     = azurerm_storage_account.storage_account.primary_connection_string
  sensitive = true
}