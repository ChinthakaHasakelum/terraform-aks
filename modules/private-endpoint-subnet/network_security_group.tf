resource "azurerm_network_security_group" "network_security_group" {
  name                = join("-", [var.project, var.environment, "private-endpoint-nsg"])
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.default_tags
}

resource "azurerm_subnet_network_security_group_association" "network_security_group_associ" {
  subnet_id                 = azurerm_subnet.private_endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}