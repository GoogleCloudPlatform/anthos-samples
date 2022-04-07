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

output "admin_vm_ssh" {
  description = "Run the following command to provision the anthos cluster."
  value = var.mode != "setup" ? null : join("\n", [
    "################################################################################",
    "##              AnthosBM on Google Compute Engine VM with Terraform           ##",
    "##                        (Run the following commands)                        ##",
    "##   (Note that the 1st command should have you SSH'ed into the admin host)   ##",
    "################################################################################",
    "",
    "> gcloud compute ssh ${var.username}@${local.admin_vm_hostnames[0]} --project=${var.project_id} --zone=${var.zone}",
    "",
    "# ------------------------------------------------------------------------------",
    "# You must be SSH'ed into the admin host ${local.admin_vm_hostnames[0]} as ${var.username} user now",
    "# ------------------------------------------------------------------------------",
    "> sudo ./run_initialization_checks.sh && \\",
    "  sudo bmctl create config -c ${var.abm_cluster_id} && \\",
    "  sudo cp ~/${var.abm_cluster_id}.yaml bmctl-workspace/${var.abm_cluster_id} && \\",
    "  sudo bmctl create cluster -c ${var.abm_cluster_id}",
    "",
    "################################################################################",
  ])
}

output "installation_check" {
  description = "Run the following command to check the Anthos bare metal installation status."
  value = var.mode != "install" ? null : join("\n", [
    "################################################################################",
    "#          SSH into the admin host and check the installation progress         #",
    "################################################################################",
    "",
    "> gcloud compute ssh ${var.username}@${local.admin_vm_hostnames[0]} --project=${var.project_id} --zone=${var.zone}",
    "> tail -f ~/install_abm.log",
    "",
    "################################################################################",
  ])
}
