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

locals {
  module_path = abspath(path.module)
  # required roles for the service account on the project that will be used for
  # the setting up the GCE infrastructure. The service account shall have
  # atleast [Editor & Project IAM Admin] roles
  editor_project_roles = [
    "roles/editor",
    "roles/resourcemanager.projectIamAdmin"
  ]
  apis_to_be_activated = ["serviceusage.googleapis.com"]
}

resource "random_id" "random_project_id_suffix" {
  byte_length = 4
}

# Create a project and service account to test the script upon a project with
# Project Editor and Project IAM Admin permissions
module "abm_infra_editor_project" {
  source              = "terraform-google-modules/project-factory/google"
  version             = "~> 13.0"
  name                = "ci-abm-${random_id.random_project_id_suffix.hex}"
  random_project_id   = true
  auto_create_network = true
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  activate_apis       = local.apis_to_be_activated
}

resource "google_service_account" "int_test_editor_sa" {
  project      = module.abm_infra_editor_project.project_id
  account_id   = "int-test-sa${random_id.random_project_id_suffix.hex}"
  display_name = "int-test-sa"
}

resource "google_project_iam_member" "project_iam_editor_binding" {
  for_each = toset(local.editor_project_roles)
  project  = module.abm_infra_editor_project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.int_test_editor_sa.email}"
}

resource "google_service_account_key" "int_test_editor_sa_key" {
  service_account_id = google_service_account.int_test_editor_sa.id
}

resource "local_file" "int_test_editor_sa_key_file" {
  content  = base64decode(google_service_account_key.int_test_editor_sa_key.private_key)
  filename = "${local.module_path}/${module.abm_infra_editor_project.project_id}.json"
}
