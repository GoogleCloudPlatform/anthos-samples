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

variable "mode" {
  type = string

  validation {
    condition     = contains(["controlplanelb", "ingresslb"], var.mode)
    error_message = "Allowed execution modes are: controlplanelb, ingresslb."
  }
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "ip_name" {
  type = string
}

variable "network" {
  type    = string
  default = "default"
}

variable "lb_endpoint_instances" {
  type    = list(object({ name = string, port = number, ip = string }))
  default = []
}

variable "health_check_path" {
  type    = string
  default = "/readyz"
}

variable "health_check_port" {
  type    = number
  default = 6444
}

variable "backend_protocol" {
  type = string

  validation {
    condition     = contains(["TCP", "HTTP"], var.backend_protocol)
    error_message = "Allowed backend protocols are: TCP, HTTP."
  }
}

variable "forwarding_rule_ports" {
  type    = list(number)
  default = [443, 80]
}


variable "create_firewall_rule" {
  type    = bool
  default = false
}

variable "firewall_rule_allow_ports" {
  type    = list(number)
  default = [443, 80]
}

variable "firewall_rule_target_tags" {
  type    = list(string)
  default = ["http-server", "https-server"]
}
