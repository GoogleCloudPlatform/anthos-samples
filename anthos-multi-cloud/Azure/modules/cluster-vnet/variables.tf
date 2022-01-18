variable "name" {
  description = "Name for the test cluster"
  type        = string
}

variable "region" {
  description = "Azure region to deploy to"
  type        = string
}

variable "aad_app_name" {
  description = "app registration name"
  type        = string
}
variable "sp_obj_id" {
  description = "app service principal object id"
  type        = string
}
variable "subscription_id" {
  description = "subscription_id "
  type        = string
}
