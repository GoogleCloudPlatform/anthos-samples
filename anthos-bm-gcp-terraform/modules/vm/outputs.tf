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

output "vm_info" {
  description = <<EOF
    Information pertaining to all the VMs that were created. It is in the form
    of a list of objects. Each object contains the hostname, internal IP address
    and the external IP address of a specific VM that was created.
  EOF
  value = flatten([
    for group in module.compute_instance[*] : [
      for vm_details in group : [
        for detail in vm_details.instances_details : {
          hostname   = detail.name
          internalIp = detail.network_interface.0.network_ip
          externalIp = detail.network_interface.0.access_config.0.nat_ip
        }
      ]
    ]
  ])
}
