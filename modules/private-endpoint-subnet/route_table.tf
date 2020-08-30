resource "azurerm_route_table" "private_endpoint_route_table" {
  name                =  join("-", [var.project, var.environment, "private-endpoint-rtable"])
  location            =  var.location
  resource_group_name =  var.resource_group_name

  route {
    name           = "ToInternet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  route {
    name           = "Local"
    address_prefix = var.address_prefixes
    next_hop_type  = "VnetLocal"
  }

  tags = var.default_tags
}

resource "azurerm_subnet_route_table_association" "private_endpoint_subnet_rt_association" {
  depends_on     = [azurerm_subnet.private_endpoint_subnet, azurerm_route_table.private_endpoint_route_table]
  subnet_id      = azurerm_subnet.private_endpoint_subnet.id
  route_table_id = azurerm_route_table.private_endpoint_route_table.id
}
