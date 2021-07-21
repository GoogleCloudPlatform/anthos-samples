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
  bmctl_version_cmd = "gcloud compute ssh tfadmin@abm-ws0-001 --project=${var.editor_project_id} --zone=us-central1-a --ssh-flag=\"-T\" -q -- bmctl version"
  docker_version_cmd = "gcloud compute ssh root@abm-ws0-001 --project=${var.editor_project_id} --zone=us-central1-a --ssh-flag=\"-T\" -q -- docker version"
}

module "anthos_bm_gcp" {
  source           = "../../../anthos-bm-gcp-terraform"
  project_id       = var.editor_project_id
  credentials_file = var.editor_sa_key_file_path
  resources_path   = "../../../anthos-bm-gcp-terraform/resources"
}
