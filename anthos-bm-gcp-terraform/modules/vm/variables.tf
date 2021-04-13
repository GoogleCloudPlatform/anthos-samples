variable "region" {
  description = "Google Cloud Region in which the VMs should be provisioned"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "VPC network to which the provisioned VMs are to be connected to"
  type        = string
  default     = "default"
}

variable "vm_names" {
  description = "List of names to be given to the Compute Engine VMs that are provisioned"
  type        = list(any)
  default     = ["ws"]
}

variable "instance_template" {
  description = "Google Cloud instance template based on which the VMs are to be provisioned"
  type        = string
}

