variable "region" {
  description = "Region where the IP addresses are to be created in"
  type        = string
}

variable "ip_names" {
  description = "List of names to be used to name the IP addresses"
  type        = list(string)
}
