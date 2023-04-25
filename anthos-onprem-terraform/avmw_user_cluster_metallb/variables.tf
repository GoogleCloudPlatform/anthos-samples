/**
 * Copyright 2023 Google LLC
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

variable "region" {
  description = <<EOT
    The Google Cloud region in which the Anthos On-Prem API runs. Specify
    a supported region.
  EOT
  type        = string
  default     = "us-west1"
}

variable "cluster_name" {
  description = "The name of the user cluster to be created"
  type        = string
  default     = "vmware-metallb-user-cluster"
}

variable "admin_cluster_name" {
  description = <<EOT
    The name of the admin cluster that manages the user cluster. The admin cluster
    name is the last segment of the fully-specified cluster name that uniquely
    identifies the cluster in Google Cloud:
    projects/FLEET_HOST_PROJECT_ID/locations/global/memberships/ADMIN_CLUSTER_NAME
  EOT
  type        = string
}

variable "on_prem_version" {
  description = <<EOT
     The Anthos clusters on the VMware version for your user cluster.
     Defaults to the admin cluster version.
  EOT
  type        = string
}

variable "control_plane_vip" {
  description = <<EOT
    The virtual IP address (VIP) that you have chosen to configure on the load
    balancer for the Kubernetes API server of the user cluster.
  EOT
  type        = string
  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.control_plane_vip))
    error_message = "Invalid IP address for Control plane VIP."
  }
}

variable "ingress_vip" {
  description = <<EOT
    The IP address that you have chosen to configure on the load balancer for
    the ingress proxy.
  EOT
  type        = string
  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.ingress_vip))
    error_message = "Invalid IP address for Ingress VIP."
  }
}

variable "control_plane_node_cpus" {
  description = <<EOT
    The number of CPUs for each admin cluster node that serve as control planes
    for this VMware user cluster.
  EOT
  type        = number
  default     = 4
}

variable "control_plane_node_memory" {
  description = <<EOT
    The megabytes of memory for each admin cluster node that serves as a
    control plane for this VMware user cluster.
  EOT
  type        = number
  default     = 8192
}

variable "control_plane_node_replicas" {
  description = <<EOT
    The number of control plane nodes for this VMware user cluster.
  EOT
  type        = number
  default     = 3
}

variable "lb_address_pools" {
  description = <<EOT
    The list of address pool configurations to be used by the MetalLB load balancer.
    Every address of each address pool must be a range either in CIDR or hyphenated-range
    format. To specify a single IP address in a pool (such as for the ingress VIP),
    use /32 in CIDR notation (ex. 192.0.2.1/32).
  EOT
  type        = list(object({ name = string, addresses = list(string) }))
}

variable "primary_apis" {
  description = "List of primary Google Cloud APIs to be enabled for this deployment"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
  ]
}
