resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = join("-", [var.project, var.environment,  "private-endpoint-subnet"])
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.address_prefixes]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.ContainerRegistry", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}