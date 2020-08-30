resource "azurerm_subnet" "aks_node_pool_subnet" {
  name                 = join("-", [var.project, var.environment, "aks-node-pool-subnet"])
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.virtual-network.virtual_network_name
  address_prefixes     = [var.aks_node_pool_subnet_address_prefix]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.ContainerRegistry", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_route_table" "aks_node_pool_route_table" {
  name                =  join("-", [var.project, var.environment,"aks-node-pool-rtable"])
  location            =  data.azurerm_resource_group.main.location
  resource_group_name =  var.resource_group_name

  route {
    name           = "ToInternet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  route {
    name           = "Local"
    address_prefix = var.aks_node_pool_subnet_address_prefix
    next_hop_type  = "VnetLocal"
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "aks_node_pool_subnet_rt_association" {
  depends_on     = [azurerm_subnet.aks_node_pool_subnet, azurerm_route_table.aks_node_pool_route_table]
  subnet_id      = azurerm_subnet.aks_node_pool_subnet.id
  route_table_id = azurerm_route_table.aks_node_pool_route_table.id
}

resource "azurerm_network_security_group" "aks_node_pool_subnet_nsg" {
  location = data.azurerm_resource_group.main.location
  name = join("-", [var.project, var.environment, "aks-node-pool-subnet-nsg"])
  resource_group_name = var.resource_group_name
}

