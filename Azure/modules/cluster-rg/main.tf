terraform {
  required_version = ">= 0.12.23"
  required_providers {
    azurerm = "= 2.44.0"
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