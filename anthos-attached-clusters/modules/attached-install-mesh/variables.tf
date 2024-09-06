/**
 * Copyright 2018-2024 Google LLC
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

variable "kubeconfig" {
  description = "The kubeconfig path."
  type        = string
}

variable "context" {
  description = "The cluster contex."
  type        = string
}

variable "fleet_id" {
  description = "The fleet_id."
  type        = string
}

variable "platform" {
  description = "Platform asmcli will run on. Valid values: linux [default], darwin. Optional."
  type        = string
  default     = "linux"
}

variable "service_account_key_file" {
  description = "Path to service account key file to run `gcloud auth activate-service-account` with. Optional."
  type        = string
  default     = ""
}

variable "use_tf_google_credentials_env_var" {
  description = "Use `GOOGLE_CREDENTIALS` environment variable to run `gcloud auth activate-service-account` with. Optional."
  type        = bool
  default     = false
}

variable "activate_service_account" {
  description = "Set to false to skip running `gcloud auth activate-service-account`. Optional."
  type        = bool
  default     = true
}

variable "gcloud_sdk_version" {
  description = "The gcloud sdk version to download. Optional."
  type        = string
  default     = "491.0.0"
}

variable "gcloud_download_url" {
  description = "Custom gcloud download url. Optional."
  type        = string
  default     = null
}

variable "jq_version" {
  description = "The jq version to download. Optional."
  type        = string
  default     = "1.6"
}

variable "jq_download_url" {
  description = "Custom jq download url. Optional."
  type        = string
  default     = null
}

variable "asmcli_version" {
  description = "The asmcli version to download. Optional."
  type        = string
  default     = "1.22"
}

variable "asmcli_download_url" {
  description = "Custom asmcli download url. Optional."
  type        = string
  default     = null
}
