output "virtual_network_name" {
  depends_on = [azurerm_virtual_network.virtual_network]
  value = azurerm_virtual_network.virtual_network.name
}

output "virtual_network_id" {
  depends_on = [azurerm_virtual_network.virtual_network]
  value = azurerm_virtual_network.virtual_network.id
}
