/**
 * Copyright 2024 Google LLC
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

variable "name_prefix" {
  description = "Common prefix to use for generating names"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project id where the cluster will be registered"
  type        = string
}

variable "gcp_location" {
  description = "GCP location to create the attached resource in"
  type        = string
  default     = "us-west1"
}

variable "platform_version" {
  description = "Platform version of the attached cluster resource"
  type        = string
  default     = "1.30.0-gke.1"
}

variable "kind_node_image" {
  description = "The image used for the kind cluster"
  type        = string
  default     = "kindest/node:v1.30.4"
}

variable "kind_api_server_address" {
  description = "Kind cluster API server address"
  type        = string
  default     = null
}

variable "kind_api_server_port" {
  description = "Kind cluster API server port"
  type        = number
  default     = null
}

variable "kubeconfig_path" {
  description = "The kubeconfig path."
  type        = string
  default     = null
}
