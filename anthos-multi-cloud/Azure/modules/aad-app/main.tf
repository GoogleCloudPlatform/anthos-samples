data "azurerm_subscription" "current" {
}
data "azuread_client_config" "current" {}

#Create an Azure Active Directory application 
#https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/how-to/create-azure-ad-application
resource "azuread_application" "aad_app" {
  display_name = var.application_name
  owners       = [data.azuread_client_config.current.object_id]
  #available_to_other_tenants = false
  #oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "aad_app" {
  application_id               = azuread_application.aad_app.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# principal to have permission for role assignment.
#https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/how-to/create-azure-role-assignments

resource "azurerm_role_assignment" "user_access_admin" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.aad_app.object_id
}
resource "azurerm_role_assignment" "key_vaule_admin" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.aad_app.object_id
}
resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aad_app.object_id
}
