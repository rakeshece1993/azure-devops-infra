resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
    rsa_bits  = 4096 
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
    name = var.virtual_machine_name
    location = var.resource_location
    resource_group_name = var.resource_group_name
    network_interface_ids = [var.network_interface_id]
    size = var.vm_size
    admin_username = var.admin_username
    disable_password_authentication = true
    admin_ssh_key {
        username = var.admin_username
        public_key = tls_private_key.ssh_key.public_key_openssh
    }
    os_disk {
        name = "${var.virtual_machine_name}-osdisk"
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    identity {
        type = "SystemAssigned"
    }
  source_image_reference {
    publisher = var.os_image_reference["publisher"]
    offer     = var.os_image_reference["offer"]
    sku       = var.os_image_reference["sku"]
    version   = var.os_image_reference["version"]
  }
tags = var.resource_tags

}
resource "azurerm_key_vault_secret" "vm_ssh_private_key" {
    name = "${var.virtual_machine_name}-ssh-private-key"
    value = tls_private_key.ssh_key.private_key_pem
    key_vault_id = var.key_vault_id
    depends_on = [ var.key_vault_id ]
    tags = var.resource_tags
}
resource "azurerm_key_vault_secret" "vm_ssh_public_key" {
    name = "${var.virtual_machine_name}-ssh-public-key"
    value = tls_private_key.ssh_key.public_key_openssh
    key_vault_id = var.key_vault_id
    depends_on = [ var.key_vault_id ]
    tags = var.resource_tags
  
}
