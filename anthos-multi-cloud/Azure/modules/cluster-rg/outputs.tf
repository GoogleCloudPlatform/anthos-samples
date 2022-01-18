output "resource_group_id" {
  description = "The id of the cluster resource group"
  value       = azurerm_resource_group.cluster.id
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
