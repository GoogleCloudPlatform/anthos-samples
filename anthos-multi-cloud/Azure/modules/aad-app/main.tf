/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "azurerm_subscription" "current" {
}
data "azuread_client_config" "current" {}

#Create an Azure Active Directory application
#https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/how-to/create-azure-ad-application
resource "azuread_application" "aad_app" {
  display_name = var.application_name
  owners       = [data.azuread_client_config.current.object_id]
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
