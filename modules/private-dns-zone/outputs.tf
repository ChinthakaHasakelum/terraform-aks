output "private_dns_zone_id" {
  depends_on = [azurerm_private_dns_zone.private_dns_zone]
  value = azurerm_private_dns_zone.private_dns_zone.id
}