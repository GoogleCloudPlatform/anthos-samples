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
  tags = {
    "owner" = var.owner
  }
}

data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "aks" {
  name     = "${var.name_prefix}-rg"
  location = var.azure_region
  tags     = merge(local.tags, var.tags)
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name_prefix}-cluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${var.name_prefix}-dns"
  kubernetes_version  = var.k8s_version

  # If not enabling the OIDC issuer, extra steps need to be taken to manually retrieve JWKs from the cluster.
  oidc_issuer_enabled = true

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_D2_v2"
    tags       = merge(local.tags, var.tags)
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.tags, var.tags)
}

data "google_project" "project" {
}

provider "helm" {
  alias = "bootstrap_installer"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
    password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

module "attached_install_manifest" {
  source                         = "../modules/attached-install-manifest"
  attached_cluster_name          = "${var.name_prefix}-cluster"
  attached_cluster_fleet_project = data.google_project.project.project_id
  gcp_location                   = var.gcp_location
  platform_version               = var.platform_version
  providers = {
    helm = helm.bootstrap_installer
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "google_container_attached_cluster" "primary" {
  name             = "${var.name_prefix}-cluster"
  project          = data.google_project.project.project_id
  location         = var.gcp_location
  description      = "AKS attached cluster example"
  distribution     = "aks"
  platform_version = var.platform_version
  oidc_config {
    issuer_url = azurerm_kubernetes_cluster.aks.oidc_issuer_url
    # NOTE: If `oidc_issuer_enabled` is not set to true above, `jwks` needs to be set here.
    # JWKs can be retrieved from the cluster using: `kubectl get --raw /openid/v1/jwks` and
    # must be base64 encoded.
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
  #   admin_users = ["user1@example.com", "user2@example.com"]
  #   admin_groups = ["group1@example.com", "group2@example.com"]
  # }

  depends_on = [
    module.attached_install_manifest
  ]
}
