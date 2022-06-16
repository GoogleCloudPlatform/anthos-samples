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


/*
 * Full Cluster terraform: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_aws_cluster
 * Full Node Pool terraform:  https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_aws_node_pool
*/

data "google_project" "project" {
}

output "project_number" {
  value = data.google_project.project.number
}

resource "google_container_aws_cluster" "this" {
  aws_region  = var.aws_region
  description = "Test AWS cluster created with Terraform"
  location    = var.location
  name        = var.anthos_prefix
  authorization {
    dynamic "admin_users" {
      for_each = var.admin_users

      content {
        username = admin_users.value
      }
    }
  }
  control_plane {
    iam_instance_profile = var.control_plane_iam_instance_profile
    instance_type        = var.control_plane_instance_type
    subnet_ids           = var.subnet_ids
    tags = {
      "Name" : "${var.anthos_prefix}-cp"
    }
    version = var.cluster_version
    aws_services_authentication {
      role_arn = var.role_arn
    }
    config_encryption {
      kms_key_arn = var.control_plane_config_encryption_kms_key_arn
    }
    database_encryption {
      kms_key_arn = var.database_encryption_kms_key_arn
    }
    main_volume {
      size_gib    = 30
      volume_type = "GP3"
      iops        = 3000
      kms_key_arn = var.control_plane_main_volume_encryption_kms_key_arn
    }
    root_volume {
      size_gib    = 30
      volume_type = "GP3"
      iops        = 3000
      kms_key_arn = var.control_plane_root_volume_encryption_kms_key_arn
    }
  }
  networking {
    pod_address_cidr_blocks     = var.pod_address_cidr_blocks
    service_address_cidr_blocks = var.service_address_cidr_blocks
    vpc_id                      = var.vpc_id
  }
  fleet {
    project = var.fleet_project
  }
  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
resource "google_container_aws_node_pool" "this" {
  name      = "${var.anthos_prefix}-nodepool"
  cluster   = google_container_aws_cluster.this.id
  subnet_id = var.node_pool_subnet_id
  version   = var.cluster_version
  location  = google_container_aws_cluster.this.location
  max_pods_constraint {
    max_pods_per_node = 110
  }
  autoscaling {
    min_node_count = 2
    max_node_count = 5
  }
  config {
    config_encryption {
      kms_key_arn = var.node_pool_config_encryption_kms_key_arn
    }
    instance_type        = var.node_pool_instance_type
    iam_instance_profile = var.node_pool_iam_instance_profile
    root_volume {
      size_gib    = 30
      volume_type = "GP3"
      iops        = 3000
      kms_key_arn = var.node_pool_root_volume_encryption_kms_key_arn
    }
    tags = {
      "Name" : "${var.anthos_prefix}-nodepool"
    }
  }
  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
