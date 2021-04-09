variable "project_id" {
  description = "Unique identifer of the Google Cloud Project that is to be used"
  type        = string
}

variable "credentials_file" {
  description = <<EOT
    Path to the Google Cloud Service Account key file.
    This is the key that will be used to authenticate the provider with the Cloud APIs
  EOT
  type        = string
}

variable "region" {
  description = "Google Cloud Region in which the Compute Engine VMs should be provisioned"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone within the selected Google Cloud Region that is to be used"
  type        = string
  default     = "us-central1-a"
}

variable "hostname_prefix" {
  description = "Unique string to prefix the hostnames of the all the Compute Enfine VMs created"
  type        = string
  default     = "abm"
}

variable "min_cpu_platform" {
  description = "Minimum CPU architecture upon which the Compute Engine VMs are to be scheduled"
  type        = string
  default     = "Intel Haswell"
}

variable "machine_type" {
  description = "Google Cloud machine type to use when provisioning the Compute Engine VMs"
  type        = string
}

variable "image_project" {
  description = "Project name of the source image to use when provisioning the Compute Engine VMs"
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "image_family" {
  description = <<EOT
    Source image to use when provisioning the Compute Engine VMs.
    The source image should be one that is in the selected image_project
  EOT
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "boot_disk_type" {
  description = "Type of the boot disk to be attached to the Compute Engine VMs"
  type        = string
  default     = "pd-ssd"
}

variable "boot_disk_size" {
  description = "Size of the primary boot disk to be attached to the Compute Engine VMs in GBs"
  type        = number
  default     = 200
}

variable "network" {
  description = "VPC network to which the provisioned Compute Engine VMs is to be connected to"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "List of tags to be associated to the provisioned Compute Engine VMs"
  type        = list(string)
  default     = ["http-server", "https-server"]
}

variable "vm_service_account" {
  description = "Service account to attach to the provisioned Compute Engine VM. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
  type = object({
    email  = string
    scopes = set(string)
  })
  default = {
    email  = ""
    scopes = ["cloud-platform"]
  }
}

variable "anthos_service_account_name" {
  description = "Name given to the Service account that will be used by the Anthos cluster components"
  type        = string
  default     = "baremetal-gcr"
}

variable "primary_apis" {
  description = "List of primary Google Cloud APIs to be enabled for this deployment"
  type        = list(string)
  default = [
    "anthos.googleapis.com",
    "anthosgke.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

variable "secondary_apis" {
  description = "List of secondary Google Cloud APIs to be enabled for this deployment"
  type        = list(string)
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
  description = "Unique id to represent the Anthos Cluster to be created"
  type        = string
  default     = "anthos-gce-cluster"
}

# [START anthos_bm_node_prefix]
variable "instance_names" {
  description = <<EOT
    List of names to be given to the Compute Engine VMs that are provisioned.
    These names will be prefixed by the string provided for the 'hostname_prefix' variable.
    The number of nodes created can be controlled by adding/removing instance_names to/from this list
  EOT
  type        = map(any)
  default = {
    "admin" : ["ws"]
    "controlplane" : ["cp1", "cp2", "cp3"]
    "worker" : ["w1", "w2"]
  }
}
# [END anthos_bm_node_prefix]
