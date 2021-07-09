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

variable "image" {
  description = <<EOF
    The source image to use when provisioning the Compute Engine VMs.
    Use 'gcloud compute images list' to find a list of all available images
  EOF
  type        = string
  default     = "ubuntu-2004-focal-v20210429"
}

variable "image_project" {
  description = "Project name of the source image to use when provisioning the Compute Engine VMs"
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "image_family" {
  description = <<EOT
    Source image to use when provisioning the Compute Engine VMs.
    The source image should be one that is in the selected image_project
  EOT
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "min_cpu_platform" {
  description = "Minimum CPU architecture upon which the Compute Engine VMs are to be scheduled"
  type        = string
  default     = "Intel Haswell"
}

variable "machine_type" {
  description = "Google Cloud machine type to use when provisioning the Compute Engine VMs"
  type        = string
  default     = "n1-standard-8"
}

variable "boot_disk_type" {
  description = "Type of the boot disk to be attached to the Compute Engine VMs"
  type        = string
  default     = "pd-ssd"
}

variable "boot_disk_size" {
  description = "Size of the primary boot disk to be attached to the Compute Engine VMs in GBs"
  type        = number
  default     = 200
}

variable "network" {
  description = "VPC network to which the provisioned Compute Engine VMs is to be connected to"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "List of tags to be associated to the provisioned Compute Engine VMs"
  type        = list(string)
  default     = ["http-server", "https-server"]
}

variable "access_scopes" {
  description = "The IAM access scopes associated to the Compute Engine VM Service Accounts"
  type        = set(string)
  default     = ["cloud-platform"]
}

variable "gpu_machine_type" {
  description = <<EOF
    The type of GPU to be attached to the provisioned GCE instances.
    See https://cloud.google.com/compute/docs/gpus for supported types
  EOF
  type        = string
  default     = ""
}

variable "gpu_count" {
  description = "The number of GPUs to be attached to the GCE instances"
  type        = number
  default     = 1
}
