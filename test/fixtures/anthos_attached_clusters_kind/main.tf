/**
 * Copyright 2024 Google LLC
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

module "anthos_attached_cluster_kind" {
  source                  = "../../../anthos-attached-clusters/kind"
  gcp_project_id          = var.gke-project-1_id
  name_prefix             = "test"
  kind_api_server_address = "172.17.0.1"
  kind_api_server_port    = 6443
  kubeconfig_path         = "/workspace/.tmp/kind-cluster"
}
