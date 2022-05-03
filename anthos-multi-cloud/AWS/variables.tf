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

variable "gcp_project_id" {
  description = "Enter the project id of the gcp project where the cluster will be registered."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to apply to all artifacts created."
  type        = string
}

# This step sets up the default RBAC policy in your cluster for a Google
# user so you can login after cluster creation
variable "admin_users" {
  description = "User to get default Admin RBAC"
  type        = list(string)
}

variable "cluster_version" {
  description = "GKE version to install"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
}

#You will need 3 AZs, one for each control plane node
variable "subnet_availability_zones" {
  description = "Availability zones to create subnets in, np will be created in the first"
  type        = list(string)
}

# Use the following command to identify the correct GCP location for a given AWS region
#gcloud container aws get-server-config --location [gcp-region]

variable "gcp_location" {
  description = "GCP location to deploy to"
  type        = string
}


variable "vpc_cidr_block" {
  description = "CIDR block to use for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cp_private_subnet_cidr_blocks" {
  description = "CIDR blocks to use for control plane private subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "np_private_subnet_cidr_blocks" {
  description = "CIDR block to use for node pool private subnets"
  type        = list(string)
  default = [
    "10.0.4.0/24"
  ]
}

#Refer to this page for information on public subnets
#https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-aws-vpc#create-sample-vpc

variable "public_subnet_cidr_block" {
  description = "CIDR blocks to use for public subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
}


variable "pod_address_cidr_blocks" {
  description = "CIDR Block to use for pod subnet"
  type        = string
  default     = "10.2.0.0/16"
}

variable "service_address_cidr_blocks" {
  description = "CIDR Block to use for service subnet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "node_pool_instance_type" {
  description = "AWS Node instance type"
  type        = string
}

variable "control_plane_instance_type" {
  description = "AWS Node instance type"
  type        = string
}
