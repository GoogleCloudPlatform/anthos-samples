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


variable "project_id" {
  description = "Unique identifer of the Google Cloud Project that is to be used"
  type        = string
}

variable "credentials_file" {
  description = <<EOT
    Path to the Google Cloud Service Account key file.
    This is the key that will be used to authenticate the provider with the Cloud APIs
  EOT
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

variable "username" {
  description = "The name of the user to be created on each Compute Engine VM to execute the init script"
  type        = string
  default     = "tfadmin"
}

variable "gcp_login_accounts" {
  description = "GCP account email addresses that must be allowed to login to the cluster using Google Cloud Identity."
  type        = list(string)
  default     = []
}

variable "mode" {
  description = <<EOF
    Indication of the execution mode. By default the terraform execution will end
    after setting up the GCE VMs where the Anthos bare metal clusters can be deployed.

    **setup:** create and initialize the GCE VMs required to install Anthos bare metal.

    **install:** everything up to 'setup' mode plus automatically run Anthos bare metal installation steps as well.

    **manuallb:** similar to 'install' mode but Anthos on bare metal is installed with ManualLB mode.
  EOF
  type        = string
  default     = "setup"

  validation {
    condition     = contains(["setup", "install", "manuallb"], var.mode)
    error_message = "Allowed execution modes are: setup, install, manuallb."
  }
}