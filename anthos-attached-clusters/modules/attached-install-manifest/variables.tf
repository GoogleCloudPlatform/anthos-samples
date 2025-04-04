/**
 * Copyright 2024-2025 Google LLC
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

variable "temp_dir" {
  description = "Directory name to temporarily write out the helm chart for bootstrapping the attach process"
  type        = string
  default     = ""
}

variable "gcp_location" {
  description = "GCP location to create the attached resource in"
  type        = string
  default     = "us-west1"
}

variable "platform_version" {
  description = "Platform version of the attached cluster resource"
  type        = string
}

variable "attached_cluster_fleet_project" {
  description = "GCP fleet project ID where the cluster will be attached"
  type        = string
}

variable "attached_cluster_name" {
  description = "Name for the attached cluster resource"
  type        = string
}

variable "helm_timeout" {
  description = "(Optional) Time in seconds to wait for Helm operations to complete."
  type        = number
  default     = null
}
