/**
 * Copyright 2022-2024 Google LLC
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

variable "location" {
  type        = string
  description = "GCP location"
}

variable "aws_region" {
  type        = string
  description = "aws region"
}

variable "cluster_version" {
  type        = string
  description = "cluster version"
}

variable "control_plane_iam_instance_profile" {
  type        = string
  description = "control plane iam instance profile"
}

variable "node_pool_iam_instance_profile" {
  type        = string
  description = "node pool iam instance profile"
}

variable "pod_address_cidr_blocks" {
  type        = list(string)
  description = "pod address cider blocks"
  default     = ["10.2.0.0/16"]
}

variable "service_address_cidr_blocks" {
  type        = list(string)
  description = "service address cidr blocks"
  default     = ["10.1.0.0/16"]
}

variable "admin_users" {
  description = "admin users"
  type        = list(string)
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "subnet_ids" {
  type        = list(string)
  description = "subnet ids"
}

variable "database_encryption_kms_key_arn" {
  type        = string
  description = "database encruption kms key arn"
}

variable "control_plane_config_encryption_kms_key_arn" {
  type        = string
  description = "control plane config encryption kms key arn"
}

variable "control_plane_root_volume_encryption_kms_key_arn" {
  type        = string
  description = "control plane root volume encryption kme key arn"
}

variable "control_plane_main_volume_encryption_kms_key_arn" {
  type        = string
  description = "control plane main volume encryption kms key arn"
}

variable "node_pool_config_encryption_kms_key_arn" {
  type        = string
  description = "node pool config encruyption kms key arn"
}

variable "node_pool_root_volume_encryption_kms_key_arn" {
  type        = string
  description = "node pool root volume encruption kms key arn"
}

variable "role_arn" {
  type        = string
  description = "role arn"
}

variable "node_pool_subnet_id" {
  type        = string
  description = "node pool subnet id"
}

variable "fleet_project" {
  type        = string
  description = "flet project"
}

variable "anthos_prefix" {
  type        = string
  description = "anthos prefix"
}

variable "control_plane_instance_type" {
  type        = string
  description = "control plane instance type"
}

variable "node_pool_instance_type" {
  type        = string
  description = "node pool instance type"
}
