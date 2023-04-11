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

#[START anthos_onprem_terraform_bare_metal_user_cluster_metallb_main]
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

# Create an anthos baremetal user cluster and enroll it with the gkeonprem API
resource "google_gkeonprem_bare_metal_cluster" "default" {
  name                     = var.cluster_name
  description              = "Anthos bare metal user cluster with MetalLB"
  provider                 = google-private
  depends_on               = [google_project_service.default]
  location                 = var.region
  bare_metal_version       = var.bmctl_version
  admin_cluster_membership = "projects/${var.project_id}/locations/global/memberships/${var.admin_cluster_name}"
  network_config {
    island_mode_cidr {
      service_address_cidr_blocks = ["172.26.0.0/16"]
      pod_address_cidr_blocks     = ["10.240.0.0/13"]
    }
  }
  control_plane {
    control_plane_node_pool_config {
      node_pool_config {
        operating_system = "LINUX"
        dynamic "node_configs" {
          for_each = var.control_plane_ips
          content {
            node_ip = node_configs.value
          }
        }
      }
    }
  }
  load_balancer {
    port_config {
      control_plane_load_balancer_port = 443
    }
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
  storage {
    lvp_share_config {
      lvp_config {
        path          = "/mnt/localpv-share"
        storage_class = "local-shared"
      }
      shared_path_pv_count = 5
    }
    lvp_node_mounts_config {
      path          = "/mnt/localpv-disk"
      storage_class = "local-disks"
    }
  }

  dynamic "security_config" {
    for_each = length(var.admin_user_emails) == 0 ? [] : [1]
    content {
      authorization {
        dynamic "admin_users" {
          for_each = var.admin_user_emails
          content {
            username = admin_users.value
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      annotations["onprem.cluster.gke.io/user-cluster-resource-link"],
      annotations["alpha.baremetal.cluster.gke.io/cluster-metrics-webhook"],
      annotations["baremetal.cluster.gke.io/operation"],
      annotations["baremetal.cluster.gke.io/operation-id"],
      annotations["baremetal.cluster.gke.io/start-time"],
      annotations["baremetal.cluster.gke.io/upgrade-from-version"]
    ]
  }
}

# Create a node pool of worker nodes for the anthos baremetal user cluster
resource "google_gkeonprem_bare_metal_node_pool" "default" {
  name               = "${var.cluster_name}-nodepool"
  display_name       = "Nodepool for ${var.cluster_name}"
  provider           = google-private
  bare_metal_cluster = google_gkeonprem_bare_metal_cluster.default.name
  location           = var.region
  node_pool_config {
    operating_system = "LINUX"
    labels           = {}

    dynamic "node_configs" {
      for_each = var.worker_node_ips
      content {
        labels  = {}
        node_ip = node_configs.value
      }
    }
  }

  lifecycle {
    ignore_changes = [
      annotations["baremetal.cluster.gke.io/gke-version"],
      annotations["baremetal.cluster.gke.io/version"],
    ]
  }
}
#[END anthos_onprem_terraform_bare_metal_user_cluster_metallb_main]
