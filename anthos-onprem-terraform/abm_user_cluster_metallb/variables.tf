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
    a supported region:
    https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/reference/supported-regions-on-prem-api
  EOT
  type        = string
  default     = "us-west1"
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

variable "bmctl_version" {
  description = <<EOT
    The Anthos clusters on bare metal version for your user cluster. The terraform
    provider based cluster creation is only supported for Anthos bare metal
    versions 1.13.1 and later
  EOT
  type        = string
  default     = "1.14.2"
}

variable "control_plane_ips" {
  description = <<EOT
    The IPv4 address of the control plane nodes. Control plane nodes run the system
    workload. Typically, you have a single machine if using a minimum deployment,
    or three machines if using a high availability (HA) deployment. Specify an odd
    number of nodes to have a majority quorum for HA. You can change these
    addresses whenever you update or upgrade a cluster
  EOT
  type        = list(string)
  validation {
    condition = alltrue([
      for ip in var.control_plane_ips :
      can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))
    ])
    error_message = "Invalid IP address for Control plane node"
  }
}

variable "worker_node_ips" {
  description = "The IPv4 address of a worker node."
  type        = list(string)
  validation {
    condition = alltrue([
      for ip in var.worker_node_ips :
      can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))
    ])
    error_message = "Invalid IP address for Worker pool node"
  }
}

variable "control_plane_vip" {
  description = <<EOT
    The virtual IP address (VIP) that you have chosen to configure on the load
    balancer for the Kubernetes API server of the user cluster.
  EOT
  type        = string
  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.control_plane_vip))
    error_message = "Invalid IP address for Control plane VIP"
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
    error_message = "Invalid IP address for Ingress VIP"
  }
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

variable "admin_user_emails" {
  description = <<EOT
    Email addresses of GCP accounts that will be designated as administrator
    accounts of the cluster. If this list is empty, the cluster creator, by default
    will be granted cluster admin privileges. However, if you include an email
    addresses in this list then those GCP accounts overrides the default. Thus,
    you will have to explicitely include the creator email as well.
  EOT
  type        = list(string)
}

variable "primary_apis" {
  description = "List of primary Google Cloud APIs to be enabled for this deployment"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
  ]
}