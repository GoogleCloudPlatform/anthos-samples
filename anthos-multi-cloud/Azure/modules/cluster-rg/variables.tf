variable "name" {
  description = "Name for the test cluster"
  type        = string
}

variable "region" {
  description = "Azure region to deploy to"
  type        = string
}

variable "sp_obj_id" {
  description = "app service principal object id"
  type        = string
}


#variable "tags" {
#  description = "The list of tags to apply to resources"
#  type        = map(string)
#}
