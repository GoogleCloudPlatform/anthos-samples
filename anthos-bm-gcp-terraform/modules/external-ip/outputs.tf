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

output "ips" {
  description = <<EOF
    IP information of all the VMs that were created. It is in the form of a map
    which has the VM hostname as the key and an object as the value. The object
    contains the IP address, tier and region.
  EOF
  value = {
    for vmName, details in google_compute_address.external_ip_address :
    vmName => ({
      region  = details.region
      tier    = details.network_tier
      address = details.address
    })
  }
}
