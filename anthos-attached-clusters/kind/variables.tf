
variable "name_prefix" {
  description = "Common prefix to use for generating names"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project id where the cluster will be registered"
  type        = string
}

variable "gcp_location" {
  description = "GCP location to create the attached resource in"
  type        = string
  default     = "us-west1"
}

variable "platform_version" {
  description = "Platform version of the attached cluster resource"
  type        = string
  default     = "1.28.0-gke.3"
}


variable "kind_node_image" {
  description = "The image used for the kind cluster"
  type        = string
  default     = "kindest/node:v1.28.0"
}



