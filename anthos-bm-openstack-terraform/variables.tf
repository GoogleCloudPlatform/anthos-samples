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

variable "external_network_id" {
  description = "The id of the external network that is used for floating IP addresses"
  type        = string
}

variable "os_auth_url" {
  description = "The OpenStack authentication URL to be used by the provider"
  type        = string
}

variable "os_user_name" {
  description = "The username to be used to authenticate the OpenStack provider client"
  type        = string
}

variable "os_password" {
  description = "The password to be used to authenticate the OpenStack provider client"
  type        = string
}

variable "os_tenant_name" {
  description = "The OpenStack tenant information for the current setup"
  type        = string
  default     = "admin"
}

variable "os_endpoint_type" {
  description = "The type of the OpenStack endpoint to use; whether its public or internal"
  type        = string
  default     = "internalURL"
}

variable "os_region" {
  description = "The OpenStack region in which the VMs are to be provisioned"
  type        = string
  default     = "RegionOne"
}

variable "network_mtu" {
  description = "The Maximum Transport Unit for packets over the OpenStack network"
  type        = number
  default     = 1400
}

variable "lb_method" {
  description = <<EOF
    The algorithm to use for load balancing requests. Valid values are
    ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP, or SOURCE_IP_PORT
  EOF
  type        = string
  default     = "ROUND_ROBIN"
}

variable "machine_type" {
  description = <<EOF
    The machine type to use when provisioning the OpenStack VMs.
    Use 'openstack flavor list' to find a list of all available flavors
  EOF
  type        = string
  default     = "m1.xlarge"
}

variable "image" {
  description = <<EOF
    The source image to use when provisioning the OpenStack VMs.
    Use 'openstack image list' to find a list of all available images
  EOF
  type        = string
  default     = "ubuntu-1804"
}

variable "ssh_key_name" {
  description = <<EOF
    The name of the SSH key pair to associate with the provisioned OpenStack VMs.
    Use 'openstack key list' to find a list of all available flavors
  EOF
  type        = string
}

# [START anthos_bm_openstack_node_count]
###################################################################################
# The recommended instance count for High Availability (HA) is 3 for Control plane
# and 2 for Worker nodes.
###################################################################################
variable "instance_count" {
  description = "Number of instances to provision per layer (Control plane and Worker nodes) of the cluster"
  type        = map(any)
  default = {
    "controlplane" : 1
    "worker" : 1
  }
}
# [END anthos_bm_openstack_node_count]
