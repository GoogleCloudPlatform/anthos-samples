variable "project_id" {}

variable "zone" {}

variable "hostname" {}

variable "credentials_file" {}

variable "publicIp" {}

variable "hostnames" {}

variable "internalIps" {}

variable "init_script" {}

variable "init_script_args" {}

variable "cluster_yaml_path" {}

variable "pub_key_path_template" {
  default = "./resources/.ssh-key-%s.pub"
}

variable "priv_key_path_template" {
  default = "./resources/.ssh-key-%s.priv"
}


