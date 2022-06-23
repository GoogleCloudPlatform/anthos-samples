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

module "external_ip_addresses" {
  source   = "../external-ip"
  region   = var.region
  ip_names = var.vm_names
}

module "compute_instance" {
  source            = "terraform-google-modules/vm/google//modules/compute_instance"
  version           = "~> 7.8.0"
  instance_template = var.instance_template
  zone              = var.zone
  for_each          = toset(var.vm_names)
  hostname          = each.value
  network           = var.network # --network default
  access_config = [{
    nat_ip       = module.external_ip_addresses.ips[each.value].address
    network_tier = module.external_ip_addresses.ips[each.value].tier
  }]
}
