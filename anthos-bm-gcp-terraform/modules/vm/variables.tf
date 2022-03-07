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

variable "region" {
  description = "Google Cloud Region in which the External IP addresses should be provisioned"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Google Cloud Zone in which the VMs should be provisioned"
  type        = string
  default     = "us-central1-a"
}

variable "network" {
  description = "VPC network to which the provisioned VMs are to be connected to"
  type        = string
  default     = "default"
}

variable "vm_names" {
  description = "List of names to be given to the Compute Engine VMs that are provisioned"
  type        = list(any)
}

variable "instance_template" {
  description = "Google Cloud instance template based on which the VMs are to be provisioned"
  type        = string
}

