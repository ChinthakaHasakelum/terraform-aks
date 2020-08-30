resource "azurerm_linux_virtual_machine" "bastion_linux_virtual_machine" {
  name                            = join("-", [var.project, var.environment, "bastion-vm"])
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  admin_username                  = var.admin_username
  computer_name                   = join("-", [var.project, var.environment, "bastion"])
  custom_data    = base64encode(file("./files/azure-user-data.sh"))
  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id
  ]

  admin_ssh_key {
    username = var.admin_username
    public_key = file(var.public_key_path)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }



  os_disk {
    name                 = join("-", [var.project, var.environment, "bastion-vm-os-disk"])
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = var.os_disk_size_gb
  }
}
