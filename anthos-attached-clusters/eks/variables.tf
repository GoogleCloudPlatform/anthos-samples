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
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-west-2"
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

variable "vpc_cidr_block" {
  description = "CIDR block to use for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks to use for public subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
}

variable "subnet_availability_zones" {
  description = "Availability zones to create subnets in"
  type        = list(string)
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
