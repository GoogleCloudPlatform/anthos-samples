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


output "project_id" {
  value = var.owner_project_id
}

output "ssh_as_tfadmin" {
  description = "gcloud command to ssh into the admin workstation as tfadmin user"
  value       = local.ssh_as_tfadmin_cmd
}

output "abm_install_check" {
  description = "gcloud command to check installation of Anthos BareMetal via ssh"
  value       = local.install_abm_cmd
}
