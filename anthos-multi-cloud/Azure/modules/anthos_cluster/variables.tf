/**
 * Copyright 2022-2024 Google LLC
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

variable "location" {
  type        = string
  description = "GCP location"
}

variable "azure_region" {
  type        = string
  description = "azure region"
}

variable "resource_group_id" {
  type        = string
  description = "resource group id"
}

variable "admin_users" {
  type        = list(string)
  description = "admin users"
}

variable "cluster_version" {
  type        = string
  description = "cluster version"
}

variable "node_pool_instance_type" {
  type        = string
  description = "node pool instance type"
}

variable "control_plane_instance_type" {
  type        = string
  description = "control plane instance type"
}

variable "subnet_id" {
  type        = string
  description = "subnet id"
}

variable "ssh_public_key" {
  type        = string
  description = "ssh public key"
}

variable "virtual_network_id" {
  type        = string
  description = "virtual network id"
}

variable "pod_address_cidr_blocks" {
  type        = list(string)
  description = "pod address cidr blocks"
  default     = ["10.200.0.0/16"]
}

variable "service_address_cidr_blocks" {
  type        = list(string)
  description = "service address cidr blocks"
  default     = ["10.32.0.0/24"]
}

variable "anthos_prefix" {
  type        = string
  description = "anthos prefix"
}

variable "tenant_id" {
  type        = string
  description = "tenant id"
}

variable "application_id" {
  type        = string
  description = "appplication id"
}

variable "fleet_project" {
  type        = string
  description = "fleet project"
}
