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

variable "vpc_cidr_block" {
  description = "CIDR block to use for VPC"
  type        = string
}
variable "aws_region" {
  description = "AWS Region to use for VPC"
  type        = string
}

variable "anthos_prefix" {
  description = "Anthos naming prefix"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks to use for public subnets"
  type        = list(string)
  default     = []
}

variable "cp_private_subnet_cidr_blocks" {
  description = "CIDR blocks to use for control plane private subnets"
  type        = list(string)
  default     = []
}

variable "np_private_subnet_cidr_blocks" {
  description = "CIDR blocks to use for node pool private subnets"
  type        = list(string)
  default     = []
}

variable "subnet_availability_zones" {
  description = "Availability zones to create subnets in"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidr_block" {
  description = "CIDR blcok to use for public subnet"
  type        = list(string)
  default     = []
}
