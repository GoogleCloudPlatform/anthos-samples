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

resource "azurerm_resource_group" "vnet" {
  location = var.region
  name     = var.name
}

#Create VNet
#https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/how-to/create-azure-vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.region
  resource_group_name = azurerm_resource_group.vnet.name
  address_space       = ["10.0.0.0/16", "10.200.0.0/16"]
}

#Create subnet
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Create Public IP
resource "azurerm_public_ip" "nat_gateway_pip" {
  name                = "${var.name}-nat-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Create NAT Gateway

resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = "${var.name}-nat-gateway"
  location                = var.region
  resource_group_name     = azurerm_resource_group.vnet.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

# associate public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_gateway" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_gateway_pip.id
}

# associate  NAT Gateway with subnet
resource "azurerm_subnet_nat_gateway_association" "default_subnet_nat_association" {
  subnet_id      = azurerm_subnet.default.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

resource "azurerm_role_definition" "this" {
  name        = "${var.aad_app_name}-role-admin"
  scope       = data.azurerm_subscription.current.id
  description = "Allow Anthos service to manage role definitions."

  permissions {
    actions = [
      "Microsoft.Authorization/roleDefinitions/read",
      "Microsoft.Authorization/roleDefinitions/write",
      "Microsoft.Authorization/roleDefinitions/delete",
    ]
    not_actions = [
    ]
  }
  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

resource "azurerm_role_assignment" "this" {
  scope = azurerm_resource_group.vnet.id
  # See bug https://github.com/hashicorp/terraform-provider-azurerm/issues/8426
  # role_definition_id = azurerm_role_definition.this.id does not work
  role_definition_id = trimsuffix(azurerm_role_definition.this.id, "|${azurerm_role_definition.this.scope}")
  principal_id       = var.sp_obj_id
}

resource "azurerm_role_definition" "vnet" {
  name        = "${var.aad_app_name}-vnet-admin"
  scope       = data.azurerm_subscription.current.id
  description = "Allow Anthos service to use and manage virtual network and role assignments"

  permissions {
    actions = [
      "*/read",
      "Microsoft.Network/*/join/action",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
    ]
    not_actions = [
    ]
  }
  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

resource "azurerm_role_assignment" "aad_app_vnet" {
  scope = azurerm_virtual_network.vnet.id
  # See bug https://github.com/hashicorp/terraform-provider-azurerm/issues/8426
  # role_definition_id = azurerm_role_definition.vnet.id does not work
  role_definition_id = trimsuffix(azurerm_role_definition.vnet.id, "|${azurerm_role_definition.vnet.scope}")
  principal_id       = var.sp_obj_id
}
