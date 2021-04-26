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
  type        = string
  description = "The id of the external network that is used for floating IP addresses."
}

variable "os_user_name" {
  type = string
}

variable "os_password" {
  type = string
}

variable "os_tenant_name" {
  type    = string
  default = "admin"
}

variable "os_auth_url" {
  type = string
}

variable "os_endpoint_type" {
  type    = string
  default = "internalURL"
}

variable "os_region" {
  type    = string
  default = "RegionOne"
}


