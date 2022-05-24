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

variable "project_number" {
}
variable "location" {
}
variable "azure_region" {
}
variable "resource_group_id" {
}
variable "admin_users" {
  type = list(string)
}
variable "cluster_version" {
}
variable "node_pool_instance_type" {
}
variable "control_plane_instance_type" {
}
variable "subnet_id" {
}
variable "ssh_public_key" {
}
variable "virtual_network_id" {
}
variable "pod_address_cidr_blocks" {
  default = ["10.200.0.0/16"]
}
variable "service_address_cidr_blocks" {
  default = ["10.32.0.0/24"]
}
variable "anthos_prefix" {
}
variable "tenant_id" {
}
variable "application_id" {
}
variable "application_object_id" {
}
variable "fleet_project" {
}
