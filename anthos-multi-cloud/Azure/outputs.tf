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

output "cluster_name" {
  description = "The automatically generated name of your Azure GKE cluster"
  value       = local.name_prefix
}
output "vars_file" {
  description = "The variables needed to create more node pools are in the vars.sh file.\n If you create additional node pools they must be manually deleted before you run terraform destroy"
  value       = "vars.sh"
}
output "vnet_resource_group" {
  description = "VNET Resource Group"
  value       = "${local.name_prefix}-vnet-rg"
}

output "cluster_resource_group" {
  description = "VNET Resource Group"
  value       = "${local.name_prefix}-rg"
}

output "message" {
  description = "Connect Instructions"
  value       = "To connect to your cluster issue the command:\n gcloud container azure clusters get-credentials ${local.name_prefix}"
}
