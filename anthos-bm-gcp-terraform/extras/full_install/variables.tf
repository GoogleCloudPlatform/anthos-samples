/**
 * Copyright 2021 Google LLC
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


variable "project_id" {
  description = "Unique identifer of the Google Cloud Project that is to be used"
  type        = string
}

variable "region" {
  description = "Google Cloud Region in which the Compute Engine VMs should be provisioned"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone within the selected Google Cloud Region that is to be used"
  type        = string
  default     = "us-central1-a"
}

variable "credentials_file" {
  description = <<EOT
    Path to the Google Cloud Service Account key file.
    This is the key that will be used to authenticate the provider with the Cloud APIs
  EOT
  type        = string
}

variable "abm_cluster_id" {
  description = "Unique id to represent the Anthos Cluster to be created"
  type        = string
  default     = "cluster1"
}

variable "resources_path" {
  description = "Path to the resources folder with the template files"
  type        = string
  default     = "../../resources"
}

variable "machine_type" {
  description = "Google Cloud machine type to use when provisioning the Compute Engine VMs"
  type        = string
  default     = "n1-standard-8"
}

variable "instance_count" {
  description = "Number of instances to provision per layer (Control plane and Worker nodes) of the cluster"
  type        = map(any)
  default = {
    "controlplane" : 3
    "worker" : 2
  }
}

variable "gpu" {
  description = <<EOF
    GPU information to be attached to the provisioned GCE instances.
    See https://cloud.google.com/compute/docs/gpus for supported types
  EOF
  type        = object({ type = string, count = number })
  default     = { count = 0, type = "" }
}

variable "gce_vm_service_account" {
  description = "Service Account to use for GCE instances"
  type        = string
  default     = ""
}
