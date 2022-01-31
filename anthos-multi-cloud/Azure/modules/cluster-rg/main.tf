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

terraform {
  required_version = ">= 0.12.23"
  required_providers {
    azurerm = "=2.94.0"
  }
}

data "azurerm_subscription" "current" {
}
data "azurerm_client_config" "current" {
}
#Create an Azure resource group
#https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/how-to/create-azure-resource-group

resource "azurerm_resource_group" "cluster" {
  name     = var.name
  location = var.region
}

#Create Azure role assignments
#https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/how-to/create-azure-role-assignments

resource "azurerm_role_assignment" "aad_app_contributor" {
  scope                = azurerm_resource_group.cluster.id
  role_definition_name = "Contributor"
  principal_id         = var.sp_obj_id
}

resource "azurerm_role_assignment" "aad_app_user_admin" {
  scope                = azurerm_resource_group.cluster.id
  role_definition_name = "User Access Administrator"
  principal_id         = var.sp_obj_id
}

resource "azurerm_role_assignment" "aad_app_keyvault_admin" {
  scope                = azurerm_resource_group.cluster.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.sp_obj_id
}
