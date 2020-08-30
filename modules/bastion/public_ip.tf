# Create public IPs
resource "azurerm_public_ip" "bastion_public_ip" {
    name                         = join("-", [var.project, var.environment, "bastion_public_ip"])
    location                     = var.location
    resource_group_name          = var.resource_group_name
    allocation_method            = "Static"

    tags = var.default_tags
}
