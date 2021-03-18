variable region {
  type    = string
  default = "us-central1"
}
variable network {
  type    = string
  default = "default"
}
variable hostname_prefix {
  type    = string
  default = "abm"
}
variable vm_names {
  type    = list(any)
  default = ["ws"]
}
variable instance_template {
  type = string
}

