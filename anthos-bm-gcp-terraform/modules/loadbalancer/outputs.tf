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

output "public_ip" {
  description = "The external ip that can be used to reach the loadbalancer that was created"
  value       = module.public_ip.ips[var.ip_name].address
}

output "neg_name" {
  description = <<EOF
        The name of the network endpoint group (https://cloud.google.com/load-balancing/docs/negs#zonal-neg)
        that was created as part of the load balancer setup
    EOF
  value       = google_compute_network_endpoint_group.lb-neg.name
}
