output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
}

output "resource_group_id" {
  description = "The id of the resource group in which resources are created"
  value       = element(coalescelist(data.azurerm_resource_group.rgrp.*.id, azurerm_resource_group.rg.*.id, [""]), 0)
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}

# Vnet and Subnets
output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = element(concat(data.azurerm_virtual_network.vnet.*.name, [""]), 0)
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = element(concat(data.azurerm_virtual_network.vnet.*.id, [""]), 0)
}

output "storage_account_id" {
  description = "The id of the storage account that was used/created"
  value       = element(concat(azurerm_storage_account.storage.*.id, data.azurerm_storage_account.storage.*.id, [""]), 0)
}

output "storage_account_name" {
  description = "The name of the storage account that was used/created"
  value       = element(concat(azurerm_storage_account.storage.*.name, data.azurerm_storage_account.storage.*.name, [""]), 0)
}
