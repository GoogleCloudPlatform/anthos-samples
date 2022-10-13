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

locals {
  install_apigee_instructions = join("\n", [
    "",
    "################################################################################",
    "#            Setup APIGEE with the new Anthos on bare metal cluster            #",
    "################################################################################",
    "> ./install_apigee.sh",
    "",
  ])
}

output "admin_vm_ssh" {
  description = "Run the following command to provision the anthos cluster."
  value = var.mode != "setup" ? null : join("\n", [
    module.install_abm_on_gce.admin_vm_ssh,
    local.install_apigee_instructions
  ])
}

output "installation_check" {
  description = "Run the following command to check the Anthos bare metal installation status."
  value = var.mode == "setup" ? null : join("\n", [
    module.install_abm_on_gce.installation_check,
    local.install_apigee_instructions
  ])
}

output "controlplane_ip" {
  description = <<EOF
    You may access the control plane nodes of the Anthos on bare metal cluster
    by accessing this IP address. You need to copy the kubeconfig file for the
    cluster from the admin workstation to access using the kubectl CLI.
  EOF
  value       = module.install_abm_on_gce.controlplane_ip
}

output "ingress_ip" {
  description = <<EOF
    You may access the application deployed in the Anthos on bare metal cluster
    by accessing this IP address
  EOF
  value       = module.install_abm_on_gce.ingress_ip
}
