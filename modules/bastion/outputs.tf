output "bastion_subnet_id" {
  depends_on = [azurerm_subnet.bastion_subnet]
  value = azurerm_subnet.bastion_subnet.id
}

output "bastion_public_ip_address" {
  depends_on = [azurerm_subnet.bastion_subnet]
  value = azurerm_public_ip.bastion_public_ip.ip_address
}

output "bastion_application_security_group_id" {
  value      = azurerm_application_security_group.bastion_application_security_group.id
  depends_on = [azurerm_application_security_group.bastion_application_security_group]
}
