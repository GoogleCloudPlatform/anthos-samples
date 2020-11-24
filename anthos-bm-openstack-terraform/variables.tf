variable "external_network_id" {
  type        = string
  description = "The id of the external network that is used for floating IP addresses."
}

variable "os_user_name" {
  type = string
}

variable "os_password" {
  type = string
}

variable "os_tenant_name" {
  type    = string
  default = "admin"
}

variable "os_auth_url" {
  type = string
}

variable "os_endpoint_type" {
  type    = string
  default = "internalURL"
}

variable "os_region" {
  type    = string
  default = "RegionOne"
}


