output "ixup_encryption_gateway_id" {
  value = azurerm_windows_virtual_machine.ixup_egw[*].id
}

output "ixup_encryption_gateway_ip" {
  value = azurerm_windows_virtual_machine.ixup_egw[*].private_ip_address
}
output "ixup_encryption_gateway_name" {
  value = local.ixup_egw_vm_name
}

output "resource_group_name" {
  value = var.resource_group_name
}