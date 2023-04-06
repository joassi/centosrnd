output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

#to get tls private key
output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}

#to get public IP of VM
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.tca_vm.public_ip_address
}