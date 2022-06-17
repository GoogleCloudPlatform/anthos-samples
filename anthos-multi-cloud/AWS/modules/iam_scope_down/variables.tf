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

variable "gcp_project_number" {
  description = "GCP project Number of project to host cluster"
  type        = string
}

variable "anthos_prefix" {
  description = "Prefix to apply to Anthos AWS Policy & Network names"
  type        = string
}

variable "access_control_tag_key" {
  description = "The tag key that applies to IAM role policies to control access to AWS resources"
  type        = string
}

variable "access_control_tag_value" {
  description = "The tag value that applies to IAM role policies to control access to AWS resources"
  type        = string
}

variable "db_kms_arn" {
  description = "DB KMS ARN"
  type        = string
}

variable "cp_main_volume_kms_arn" {
  description = "Control Plane Main Volume KMS ARN"
  type        = string
}

variable "cp_config_kms_arn" {
  description = "Control Plane Configuration KMS ARN"
  type        = string
}

variable "np_config_kms_arn" {
  description = "Node Pool Configuration KMS ARN"
  type        = string
}
