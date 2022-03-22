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
  description = "Google Cloud Project where the target resources live"
  type        = string
}

variable "credentials_file" {
  description = <<EOT
    Path to the Google Cloud Service Account key file.
    This is the key that will be used to authenticate the provider with the Cloud APIs
  EOT
  type        = string
}

variable "resources_path" {
  description = "Path to the resources folder with the template files"
  type        = string
}

variable "zone" {
  description = "Google Cloud Zone where the target VM is in"
  type        = string
  default     = "us-central1-a"
}

variable "username" {
  description = "The name of the user to be created to execute the init script"
  type        = string
  default     = "tfadmin"
}

variable "hostname" {
  description = "Hostname of the target VM"
  type        = string
}

variable "publicIp" {
  description = "Publicly accessible IP address of the target VM"
  type        = string
}

variable "init_script" {
  description = "Path to the initilization script that is to be run on the target VM"
  type        = string
  default     = "../../resources/init_vm.sh"
}

variable "init_check_script" {
  description = "Path to the script that validates if the initialization is complete"
  type        = string
  default     = "../../resources/run_initialization_checks.sh"
}

variable "install_abm_script" {
  description = "Path to the script that installs Anthos on bare metal"
  type        = string
  default     = "../../resources/install_abm.sh"
}

variable "login_script" {
  description = "Path to the script that generates the token used to login to the Anthos bare metal cluster"
  type        = string
  default     = "../../resources/login.sh"
}

variable "init_logs" {
  description = "Name of the file to write the logs of the initialization script"
  type        = string
  default     = "init.log"
}

variable "init_vars_file" {
  description = "Path to the file containing the host specific arguments to the init script"
  type        = string
}

variable "cluster_yaml_path" {
  description = "Path to the YAML configuration file describing the Anthos cluster"
  type        = string
  default     = "../../resources/.cluster1.yaml"
}

variable "pub_key_path_template" {
  description = "Template denoting the path where the public key is to be stored"
  type        = string
  default     = "../../resources/.ssh-key-%s.pub"
}

variable "priv_key_path_template" {
  description = "Template denoting the path where the private key is to be stored"
  type        = string
  default     = "../../resources/.ssh-key-%s.priv"
}
