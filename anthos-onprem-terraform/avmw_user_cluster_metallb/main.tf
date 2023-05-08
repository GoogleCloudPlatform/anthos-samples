/**
 * Copyright 2023 Google LLC
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

#[START anthos_onprem_terraform_vmware_user_cluster_metallb_main]
module "enable_google_apis_primary" {
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "~> 14.0"
  project_id = var.project_id
  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "anthos.googleapis.com",
    "anthosgke.googleapis.com",
    "container.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "anthosaudit.googleapis.com",
    "opsconfigmonitoring.googleapis.com",
    "file.googleapis.com",
    "connectgateway.googleapis.com"
  ]
  disable_services_on_destroy = false
}

# Enable GKE OnPrem API
resource "google_project_service" "default" {
  project            = var.project_id
  service            = "gkeonprem.googleapis.com"
  disable_on_destroy = false
}

# Create an anthos vmware user cluster and enroll it with the gkeonprem API
resource "google_gkeonprem_vmware_cluster" "default" {
  name                     = var.cluster_name
  description              = "Anthos VMware user cluster with MetalLB"
  provider                 = google-beta
  depends_on               = [google_project_service.default]
  location                 = var.region
  on_prem_version          = var.on_prem_version
  admin_cluster_membership = "projects/${var.project_id}/locations/global/memberships/${var.admin_cluster_name}"
  network_config {
    service_address_cidr_blocks = ["10.96.0.0/12"]
    pod_address_cidr_blocks     = ["192.168.0.0/16"]
    dhcp_ip_config {
      enabled = true
    }
  }
  control_plane_node {
    cpus     = var.control_plane_node_cpus
    memory   = var.control_plane_node_memory
    replicas = var.control_plane_node_replicas
  }
  load_balancer {
    vip_config {
      control_plane_vip = var.control_plane_vip
      ingress_vip       = var.ingress_vip
    }
    metal_lb_config {
      dynamic "address_pools" {
        for_each = var.lb_address_pools
        content {
          pool      = address_pools.value.name
          addresses = address_pools.value.addresses
        }
      }
    }
  }
}

# Create a node pool for the anthos vmware user cluster
resource "google_gkeonprem_vmware_node_pool" "default" {
  name           = "${var.cluster_name}-nodepool"
  display_name   = "Nodepool for ${var.cluster_name}"
  provider       = google-beta
  vmware_cluster = google_gkeonprem_vmware_cluster.default.name
  location       = var.region
  config {
    replicas   = 3
    image_type = "ubuntu_containerd"
  }
  depends_on = [
    google_gkeonprem_vmware_cluster.default
  ]
}
#[END anthos_onprem_terraform_vmware_user_cluster_metallb_main]
