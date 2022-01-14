variable "gcp_project_id" {
  description = "GCP project ID to register the Anthos Cluster to"
  type        = string
}
variable "azure_region" {
  description = "Azure region to deploy to"
  type        = string

}

variable "gcp_location" {
  description = "GCP region to deploy the multi-cloud API"
  type        = string
}

variable "name_prefix" {
  description = "prefix of all artifacts created and cluster name"
  type        = string
}

variable "admin_user" {
  description = "GCP User to give admin RBAC to in the cluster"
  type        = string
}

variable "cluster_version" {
  description = "GKE version to install"
  type        = string
}

variable "node_pool_instance_type" {
  description = "Azure instance type for node pool"
  type        = string
}
