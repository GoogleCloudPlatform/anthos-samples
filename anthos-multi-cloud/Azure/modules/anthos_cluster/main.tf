/**
 * Copyright 2022 Google LLC
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

module "azure_client" {
  source         = "./client"
  anthos_prefix  = var.anthos_prefix
  location       = var.location
  tenant_id      = var.tenant_id
  application_id = var.application_id
}

resource "azuread_application_certificate" "aad_app_azure_client_cert" {
  application_object_id = var.application_object_id
  type                  = "AsymmetricX509Cert"
  value                 = module.azure_client.certificate
  end_date_relative     = "8760h"
}

resource "time_sleep" "wait_for_aad_app_azure_client_cert" {
  create_duration = "20s"
  depends_on      = [azuread_application_certificate.aad_app_azure_client_cert]
}

resource "google_container_azure_cluster" "this" {
  client            = "projects/${var.project_number}/locations/${var.location}/azureClients/${module.azure_client.client_name}"
  azure_region      = var.azure_region
  description       = "Test Azure GKE cluster created with Terraform"
  location          = var.location
  name              = var.anthos_prefix
  resource_group_id = var.resource_group_id
  authorization {
    admin_users {
      username = var.admin_user
    }
  }
  control_plane {
    subnet_id = var.subnet_id
    tags = {
      "client" : "Terraform"
    }
    version = var.cluster_version
    vm_size = "Standard_DS2_v2"
    main_volume {
      size_gib = 8
    }
    root_volume {
      size_gib = 32
    }
    ssh_config {
      authorized_key = var.ssh_public_key
    }
  }
  networking {
    pod_address_cidr_blocks     = var.pod_address_cidr_blocks
    service_address_cidr_blocks = var.service_address_cidr_blocks
    virtual_network_id          = var.virtual_network_id
  }
  fleet {
    project = var.fleet_project
  }
  depends_on = [time_sleep.wait_for_aad_app_azure_client_cert]
  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

resource "google_container_azure_node_pool" "azure_node_pool" {
  cluster   = google_container_azure_cluster.this.id
  version   = var.cluster_version
  location  = var.location
  name      = "${var.anthos_prefix}-np-1"
  subnet_id = var.subnet_id
  autoscaling {
    min_node_count = 2
    max_node_count = 5
  }
  config {
    tags = {
      "client" : "Terraform"
    }
    vm_size = var.node_pool_instance_type
    root_volume {
      size_gib = 32
    }
    ssh_config {
      authorized_key = var.ssh_public_key
    }
  }
  max_pods_constraint {
    max_pods_per_node = 110
  }
  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
