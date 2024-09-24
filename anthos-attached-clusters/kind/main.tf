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


// This is an example of how you might use the attached module with a local kind cluster

locals {
  cluster_name    = "${var.name_prefix}-cluster"
  cluster_context = jsondecode(jsonencode(yamldecode(kind_cluster.cluster.kubeconfig).contexts))[0].name
}

resource "kind_cluster" "cluster" {
  name       = local.cluster_name
  node_image = var.kind_node_image

  kubeconfig_path = var.kubeconfig_path != null ? var.kubeconfig_path : "${path.root}/.tmp/kube/${local.cluster_name}"

  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    feature_gates = {
      KubeletInUserNamespace : "true"
    }
    networking {
      api_server_address = var.kind_api_server_address
      api_server_port    = var.kind_api_server_port
    }
  }
}

provider "helm" {
  alias = "bootstrap_installer"
  kubernetes {
    host                   = kind_cluster.cluster.endpoint
    client_certificate     = kind_cluster.cluster.client_certificate
    client_key             = kind_cluster.cluster.client_key
    cluster_ca_certificate = kind_cluster.cluster.cluster_ca_certificate
  }
}

module "attached_install_manifest" {
  source                         = "../modules/attached-install-manifest"
  attached_cluster_name          = local.cluster_name
  attached_cluster_fleet_project = data.google_project.project.project_id
  gcp_location                   = var.gcp_location
  platform_version               = var.platform_version
  providers = {
    helm = helm.bootstrap_installer
  }
  depends_on = [
    kind_cluster.cluster
  ]
}

data "google_project" "project" {
  project_id = var.gcp_project_id
}

module "oidc" {
  source = "./oidc"

  endpoint               = kind_cluster.cluster.endpoint
  cluster_ca_certificate = kind_cluster.cluster.cluster_ca_certificate
  client_certificate     = kind_cluster.cluster.client_certificate
  client_key             = kind_cluster.cluster.client_key
}

resource "google_container_attached_cluster" "primary" {
  name             = local.cluster_name
  project          = data.google_project.project.project_id
  location         = var.gcp_location
  description      = "Kind attached cluster example"
  distribution     = "generic"
  platform_version = var.platform_version
  oidc_config {
    issuer_url = module.oidc.issuer
    jwks       = module.oidc.jwks
  }
  fleet {
    project = "projects/${data.google_project.project.number}"
  }

  # Optional:
  # logging_config {
  #   component_config {
  #     enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  #   }
  # }

  # Optional:
  # monitoring_config {
  #   managed_prometheus_config {
  #     enabled = true
  #   }
  # }

  # Optional:
  # authorization {
  #   admin_users = ["user1@google.com", ]
  #   admin_groups = ["group1@example.com", "group2@example.com"]
  # }

  depends_on = [
    module.attached_install_manifest
  ]
}

# Install Cloud Service Mesh
module "install-mesh" {
  source = "../modules/attached-install-mesh"

  kubeconfig = kind_cluster.cluster.kubeconfig_path
  context    = local.cluster_context
  fleet_id   = data.google_project.project.project_id

  asmcli_enable_cluster_roles      = true
  asmcli_enable_cluster_labels     = true
  asmcli_enable_gcp_components     = true
  asmcli_enable_namespace_creation = true

  depends_on = [
    google_container_attached_cluster.primary
  ]
}
