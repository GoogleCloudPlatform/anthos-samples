output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.default.id
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the subnet"
  value       = azurerm_subnet.default.address_prefixes
}

output "vnet_id" {
  description = "The ID of the vnet"
  value       = azurerm_virtual_network.vnet.id
}

output "location" {
  description = "The location/region of vnet"
  value       = azurerm_virtual_network.vnet.location
}
