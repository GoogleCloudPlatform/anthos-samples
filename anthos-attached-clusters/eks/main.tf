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
  cluster_name = "${var.name_prefix}-cluster"
}

resource "aws_eks_cluster" "eks" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  version = var.k8s_version

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
  ]
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.id
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.public[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

data "google_project" "project" {
}

provider "helm" {
  alias = "bootstrap_installer"
  kubernetes {
    host                   = aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
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
  # Ensure the node group and route are destroyed after we uninstall the manifest.
  # `terraform destroy` will fail if the module can't access the cluster to clean up.
  depends_on = [ 
    aws_eks_node_group.node,
    aws_route.public_internet_gateway,
    aws_route_table_association.public,
  ]
}

resource "google_container_attached_cluster" "primary" {
  name             = "${var.name_prefix}-cluster"
  project          = data.google_project.project.project_id
  location         = var.gcp_location
  description      = "EKS attached cluster example"
  distribution     = "eks"
  platform_version = var.platform_version
  oidc_config {
    issuer_url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
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
