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

variable "type" {
  description = <<EOF
    Indication of the type of loadbalancer you want to create; whether it is a
    L4 loadbalancer for the control plane of the cluster or a L7 loadbalancer
    for the Ingress controller. Supported values are: controlplanelb, ingresslb
  EOF
  type        = string

  validation {
    condition     = contains(["controlplanelb", "ingresslb"], var.type)
    error_message = "Allowed load balancer types are: controlplanelb, ingresslb."
  }
}

variable "project" {
  description = "Unique identifer of the Google Cloud Project that is to be used"
  type        = string
}

variable "region" {
  description = "Google Cloud Region in which the loadbalancer resources should be provisioned"
  type        = string
}

variable "zone" {
  description = "Zone within the selected Google Cloud Region that is to be used"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to associate to the names of the loadbalancer resources created by this module"
  type        = string
}

variable "ip_name" {
  description = "Name to be given to the external IP that is created to expose the loadbalancer"
  type        = string
}

variable "network" {
  description = "VPC network to which the loadbalancer resources are connected to"
  type        = string
  default     = "default"
}

variable "lb_endpoint_instances" {
  description = <<EOF
  Details (name, port, ip) of the backend instances that the loadbalancer will
  distribute traffic to
  EOF
  type        = list(object({ name = string, port = number, ip = string }))
  default     = []
}

variable "health_check_path" {
  description = <<EOF
  URL context to use when pinging the backend instances (of the loadbalancer) to
  do health checks. Health checks are used to verify if the instance is
  available to receive loadbalanced traffic
  EOF
  type        = string
  default     = "/readyz"
}

variable "health_check_port" {
  description = <<EOF
  Network port on the backend instance to use when pinging to do health checks.
  Health checks are used to verify if the instance is available to receive
  loadbalanced traffic
  EOF
  type        = number
  default     = 6444
}

variable "backend_protocol" {
  description = <<EOF
  The type of network traffic that the loadbalancer is expected to load balance.
  This attribute defines the type of loadbalancer that is created.
  https://cloud.google.com/load-balancing/docs/load-balancing-overview#summary-of-google-cloud-load-balancers
  EOF
  type        = string
  validation {
    condition     = contains(["TCP", "HTTP"], var.backend_protocol)
    error_message = "Allowed backend protocols are: TCP, HTTP."
  }
}

variable "forwarding_rule_ports" {
  description = <<EOF
  List of ports on the external IP address (created by this module) that should
  have a forwarding rule associated to them. The forwarding rule configures
  traffic to these ports on the external IP to be forwarded to the loadbalancer.
  EOF
  type        = list(number)
  default     = [443, 80]
}
