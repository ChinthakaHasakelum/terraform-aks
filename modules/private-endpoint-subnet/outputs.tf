output "private_endpoint_subnet_id" {
  depends_on = [azurerm_subnet.private_endpoint_subnet]
  value = azurerm_subnet.private_endpoint_subnet.id
}