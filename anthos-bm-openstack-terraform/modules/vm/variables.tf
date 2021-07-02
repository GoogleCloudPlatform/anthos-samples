
variable "vm_names" {
  description = "List of names to be given to the OpenStack VMs that are provisioned"
  type        = list(any)
}

variable "image" {
  description = <<EOF
    The source image to use when provisioning the OpenStack VMs.
    Use 'openstack image list' to find a list of all available images
  EOF
  type        = string
  default     = "ubuntu-1804"
}

variable "flavor" {
  description = <<EOF
    The machine type to use when provisioning the OpenStack VMs.
    Use 'openstack flavor list' to find a list of all available flavors
  EOF
  type        = string
  default     = "m1.xlarge"
}

variable "key" {
  description = <<EOF
    The key pair to associate with the provisioned the OpenStack VMs.
    Use 'openstack key list' to find a list of all available flavors
  EOF
  type        = string
  default     = "abm_key"
}

variable "security_groups" {
  description = <<EOF
    The security groups to which the provisioned OpenStack VMs are to be
    associated to.
  EOF
  type        = list(string)
  default     = ["default"]
}

variable "user_data" {
  description = <<EOF
    The user data to be provided to the cloud-init system on the provisioned
    VMs. This will be used to setup the VM on first boot.
  EOF
  type        = string
  default     = ""
}

variable "network" {
  description = "The OpenStack network to which the VM is to be attached to."
  type        = string
}

### For testing
variable "ip" {
  type        = string
}
