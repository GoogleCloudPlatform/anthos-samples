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
