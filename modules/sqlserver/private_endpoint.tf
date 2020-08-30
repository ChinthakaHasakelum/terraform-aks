resource "azurerm_private_endpoint" "private_endpoint" {
  count = length(var.private_endpoint_subnets)

  name = format(
    "%s-private-ep-${var.db_name}",
    element(split("/", var.private_endpoint_subnets[count.index]), 10) # Subnet name
  )

  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnets[count.index]

  private_service_connection {
    name = format(
      "%s-private-sc-${var.db_name}",
      element(split("/", var.private_endpoint_subnets[count.index]), 10) # Subnet name
    )
    private_connection_resource_id = azurerm_sql_server.server.id
    subresource_names              = [ "sqlServer" ]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = format(
      "%s-private-dns-${var.db_name}",
      element(split("/", var.private_endpoint_subnets[count.index]), 10) # Subnet name
    )
    private_dns_zone_ids = var.private_dns_zone_ids
  }
}

