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

locals {
  temp_dir           = var.temp_dir == "" ? "${path.root}/.tmp" : var.temp_dir
  helm_chart_name    = "attached-bootstrap"
  module_install_dir = "${var.gcp_location}-${var.platform_version}"
  helm_chart_dir     = "${local.temp_dir}/${local.module_install_dir}/bootstrap_helm_chart"
}

# Get the install manifest from the attached clusters service.
data "google_container_attached_install_manifest" "bootstrap" {
  location         = var.gcp_location
  project          = var.attached_cluster_fleet_project
  cluster_id       = var.attached_cluster_name
  platform_version = var.platform_version
}

# Write out the helm chart index.
resource "local_file" "bootstrap_helm_chart" {
  filename = "${local.helm_chart_dir}/Chart.yaml"
  content  = <<-EOT
    apiVersion: v2
    name: ${local.helm_chart_name}
    version: 0.0.0
    type: application
    EOT
}

# Write out the install manifest as the helm chart.
resource "local_file" "bootstrap_manifests" {
  filename = "${local.helm_chart_dir}/templates/bootstrap.yaml"
  content  = data.google_container_attached_install_manifest.bootstrap.manifest
}

# Apply the helm chart to the cluster.
resource "helm_release" "local" {
  name       = local.helm_chart_name
  chart      = local.helm_chart_dir
  depends_on = [local_file.bootstrap_helm_chart, local_file.bootstrap_manifests]
}
