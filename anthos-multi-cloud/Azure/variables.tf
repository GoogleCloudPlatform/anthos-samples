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

variable "gcp_project_id" {
  description = "GCP project ID to register the Anthos Cluster to"
  type        = string
}
variable "azure_region" {
  description = "Azure region to deploy to"
  type        = string

}

variable "gcp_location" {
  description = "GCP region to deploy the multi-cloud API"
  type        = string
}

variable "name_prefix" {
  description = "prefix of all artifacts created and cluster name"
  type        = string
}

# This step sets up the default RBAC policy in your cluster for a Google
# user so you can login after cluster creation
variable "admin_users" {
  description = "User to get default Admin RBAC"
  type        = list(string)
}

variable "cluster_version" {
  description = "GKE version to install"
  type        = string
}

variable "node_pool_instance_type" {
  description = "Azure instance type for node pool"
  type        = string
}

variable "control_plane_instance_type" {
  description = "Azure instance type for control plane"
  type        = string
}
