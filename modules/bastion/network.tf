resource "azurerm_subnet" "bastion_subnet" {
  name                 = join("-", [var.project, var.environment, "bastion-subnet"])
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.subnet_address_prefix]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_route_table" "bastion_route_table" {
  name                =  join("-", [var.project, var.environment, "bastion-rtable"])
  location            =  var.location
  resource_group_name =  var.resource_group_name

  tags = var.default_tags
}

resource "azurerm_route" "internet_route" {
  name                = "ToInternet"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.bastion_route_table.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "bastion_subnet_rt_association" {
  subnet_id      = azurerm_subnet.bastion_subnet.id
  route_table_id = azurerm_route_table.bastion_route_table.id
  depends_on     = [azurerm_subnet.bastion_subnet, azurerm_route_table.bastion_route_table]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "bastion_nsg" {
    name                = join("-", [var.project, var.environment, "bastion-nsg"])
    location            = var.location
    resource_group_name = var.resource_group_name

    tags = var.default_tags
}

resource "azurerm_network_security_rule" "network_security_rule_allow_public_ssh_inbound" {
  name                        = "Allow Public SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.nsg_source_address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

resource "azurerm_network_security_rule" "network_security_rule_block_vnet_inbound" {
  name                        = "Block Inbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

# Create network interface
resource "azurerm_network_interface" "bastion_nic" {
    name                      = join("-", [var.project, var.environment, "bastion-nic"])
    location                  = var.location
    resource_group_name       = var.resource_group_name
    depends_on                = [azurerm_subnet.bastion_subnet, azurerm_public_ip.bastion_public_ip]

    ip_configuration {
        name                          = join("-", [var.project, var.environment, "bastion-nic-conf"])
        subnet_id                     = azurerm_subnet.bastion_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.bastion_public_ip.id
    }

    tags = var.default_tags
}

# Connect the security group to the subnet
resource "azurerm_subnet_network_security_group_association" "bastion_sec_association" {
    subnet_id                 = azurerm_subnet.bastion_subnet.id
    network_security_group_id = azurerm_network_security_group.bastion_nsg.id
    depends_on                = [azurerm_subnet.bastion_subnet, azurerm_network_security_group.bastion_nsg]
}

resource "azurerm_application_security_group" "bastion_application_security_group" {
  name                = join("-", [var.project, var.environment, "bastion-asg"])
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.default_tags
}

resource "azurerm_network_interface_application_security_group_association" "bastion_asg_association" {
  network_interface_id          = azurerm_network_interface.bastion_nic.id
  application_security_group_id = azurerm_application_security_group.bastion_application_security_group.id
  depends_on                    = [azurerm_network_interface.bastion_nic, azurerm_application_security_group.bastion_application_security_group]
}
