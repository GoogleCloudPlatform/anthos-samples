output "subscription_id" {
  description = "The ID of the subscription"
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "The ID of the tenant"
  value       = data.azurerm_subscription.current.tenant_id
}

output "aad_app_id" {
  description = "The id of the aad app registration"
  value       = azuread_application.aad_app.application_id
}

output "aad_app_obj_id" {
  description = "The object id of the aad app registration"
  value       = azuread_application.aad_app.object_id
}

output "aad_app_sp_obj_id" {
  description = "The object id of the aad service principal"
  value       = azuread_service_principal.aad_app.object_id
}