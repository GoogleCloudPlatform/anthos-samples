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

variable "location" {
}
variable "aws_region" {
}
variable "cluster_version" {
}
variable "control_plane_iam_instance_profile" {
}
variable "node_pool_iam_instance_profile" {
}
variable "pod_address_cidr_blocks" {
  default = ["10.2.0.0/16"]
}
variable "service_address_cidr_blocks" {
  default = ["10.1.0.0/16"]
}
variable "admin_users" {
  type = list(string)
}
variable "vpc_id" {
}
variable "subnet_ids" {
}
variable "database_encryption_kms_key_arn" {
}
variable "control_plane_config_encryption_kms_key_arn" {
}
variable "control_plane_root_volume_encryption_kms_key_arn" {
}
variable "control_plane_main_volume_encryption_kms_key_arn" {
}
variable "node_pool_config_encryption_kms_key_arn" {
}
variable "node_pool_root_volume_encryption_kms_key_arn" {
}
variable "role_arn" {
}
variable "node_pool_subnet_id" {
}
variable "fleet_project" {
}
variable "anthos_prefix" {
}
variable "control_plane_instance_type" {
}
variable "node_pool_instance_type" {
}
