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
    admin_users {
      username = var.admin_user
    }
  }
  control_plane {
    iam_instance_profile = var.iam_instance_profile
    instance_type        = "t3.medium"
    subnet_ids           = var.subnet_ids
    tags = {
      "Name" : "${var.anthos_prefix}-cp"
    }
    version = var.cluster_version
    aws_services_authentication {
      role_arn = var.role_arn
    }
    config_encryption {
      kms_key_arn = var.database_encryption_kms_key_arn
    }
    database_encryption {
      kms_key_arn = var.database_encryption_kms_key_arn
    }
    main_volume {
      size_gib    = 30
      volume_type = "GP3"
      iops        = 3000
      kms_key_arn = var.volume_kms_key_arn
    }
    root_volume {
      size_gib    = 30
      volume_type = "GP3"
      iops        = 3000
      kms_key_arn = var.volume_kms_key_arn
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
      kms_key_arn = var.database_encryption_kms_key_arn
    }
    instance_type        = "t3.medium"
    iam_instance_profile = var.iam_instance_profile
    root_volume {
      size_gib    = 30
      volume_type = "GP3"
      iops        = 3000
      kms_key_arn = var.volume_kms_key_arn
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
