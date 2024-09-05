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

output "PROJECT" {
  description = "cluster project"
  value       = google_container_attached_cluster.primary.project
}

output "CLUSTER" {
  description = "cluster name"
  value       = google_container_attached_cluster.primary.name
}

output "KUBECONFIG" {
  description = "cluster kubeconfig"
  value       = kind_cluster.cluster.kubeconfig_path
}

output "CONTEXT" {
  description = "cluster context"
  value       = local.cluster_context
}
