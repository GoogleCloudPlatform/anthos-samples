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

resource "openstack_compute_instance_v2" "openstack_instance" {
  for_each        = { for index, vm in var.vm_info : index => vm }
  name            = each.value.name
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = var.key
  security_groups = var.security_groups
  user_data       = var.user_data
  network {
    uuid        = var.network
    fixed_ip_v4 = each.value.ip
  }
}
