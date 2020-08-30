resource "azurerm_managed_disk" "bastion_vm_managed_disk" {
  name                 = join("-", [var.project, var.environment, "bastion-vm-managed-disk"])
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.managed_disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "bastion_vm_managed_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.bastion_vm_managed_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.bastion_linux_virtual_machine.id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on         = [azurerm_linux_virtual_machine.bastion_linux_virtual_machine, azurerm_managed_disk.bastion_vm_managed_disk]
}
