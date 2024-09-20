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

# Outputs to be used by tests on the project with Editor & Project IAM Admin
# permissions
output "editor_project_id" {
  value = module.abm_infra_editor_project.project_id
}

output "editor_sa_email" {
  value = google_service_account.int_test_editor_sa.email
}

output "editor_sa_key" {
  value     = google_service_account_key.int_test_editor_sa_key.private_key
  sensitive = true
}

output "editor_sa_key_file_path" {
  value = "${abspath(path.module)}/${module.abm_infra_editor_project.project_id}.json"
}

output "gke-project-1_id" {
  value = module.gke-project-1.project_id
}
