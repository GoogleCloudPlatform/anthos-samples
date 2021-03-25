variable "project_id" {}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-a"
}

variable "credentials_file" {}

variable "hostname_prefix" {
  default = "abm"
}

variable "machine_type" {}

variable "image_family" {
  default = "ubuntu-2004-lts"
}

variable "image_project" {
  default = "ubuntu-os-cloud"
}

variable "boot_disk_size" {
  default = 200
}

variable "boot_disk_type" {
  default = "pd-ssd"
}

variable "network" {
  default = "default"
}

variable "min_cpu_platform" {
  default = "Intel Haswell"
}

variable "tags" {
  type        = list(string)
  description = "Network tags, provided as a list"
  default     = ["http-server", "https-server"]
}

variable "service_account" {
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
  type = object({
    email  = string
    scopes = set(string)
  })
  default = {
    email  = ""
    scopes = ["cloud-platform"]
  }
}

variable "primary_apis" {
  description = "The list of GCP APIs to be enabled for this deployment"
  default = [
    "anthos.googleapis.com",
    "anthosgke.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

variable "secondary_apis" {
  description = "The list of GCP APIs to be enabled for this deployment"
  default = [
    "container.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
  ]
}

variable "abm_cluster_id" {
  default = "anthos-gce-cluster"
}
variable "instance_names" {
  type = map(any)
  default = {
    "admin" : ["ws"]
    "controlplane" : ["cp1", "cp2", "cp3"]
    "worker" : ["w1", "w2"]
  }
}
