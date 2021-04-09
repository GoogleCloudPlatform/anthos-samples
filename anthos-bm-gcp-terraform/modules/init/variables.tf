variable "project_id" {
  description = "Google Cloud Project where the target resources live"
  type        = string
}

variable "credentials_file" {
  description = <<EOT
    Path to the Google Cloud Service Account key file.
    This is the key that will be used to authenticate the provider with the Cloud APIs
  EOT
  type        = string
}

variable "zone" {
  description = "Google Cloud Zone where the target VM is in"
  type        = string
  default     = "us-central1-a"
}

variable "hostname" {
  description = "Hostname of the target VM"
  type        = string
}

variable "publicIp" {
  description = "Publicly accessible IP address of the target VM"
  type        = string
}

variable "hostnames" {
  description = "List of hostnames of all the VMs to which the target VM should have SSH configured"
  type        = string
}

variable "internalIps" {
  description = "List of VPC internal IP addresses that is to be added to the target VM's VxLAN bridge"
  type        = string
}

variable "init_script" {
  description = "Path to the initilization script that is to be run on the target VM"
  type        = string
  default     = "../../resources/init.sh"
}

variable "init_script_args" {
  description = <<EOF
    Space separated list of arguments to be passed into the initialization script.
    This shall include atleast 2 arguments:
      1. Zone (string)
      2. Is the VM an admin VM (boolean)
      3. VxLAN IP address of the VM (string)
    e.g. "us-central1-a true 10.200.0.3"
  EOF
  type        = string
}

variable "cluster_yaml_path" {
  description = "Path to the YAML configuration file describing the Anthos cluster"
  type        = string
  default     = "../../resources/.anthos-gce-cluster.yaml"
}

variable "pub_key_path_template" {
  description = "Template denoting the path where the public key is to be stored"
  type        = string
  default     = "./resources/.ssh-key-%s.pub"
}

variable "priv_key_path_template" {
  description = "Template denoting the path where the private key is to be stored"
  type        = string
  default     = "./resources/.ssh-key-%s.priv"
}
