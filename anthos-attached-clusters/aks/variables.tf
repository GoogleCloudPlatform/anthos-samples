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
 
variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "name_prefix" {
  description = "Common prefix to use for generating names"
  type    = string
}

variable "azure_region" {
  description = "Azure region to deploy to"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "List of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "k8s_version" {
  description = "Kubernetes version of the AKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_count" {
  description = "The number of nodes in the default node pool"
  type        = number
  default     = 1
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
  default     = "1.28.0-gke.3"
}
