resource "openstack_compute_instance_v2" "openstack_instance" {
  for_each        = { for index, vm in var.vm_info : index => vm }
  name            = each.value.name
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = var.key
  security_groups = var.security_groups
  user_data       = var.user_data
  network {
    uuid        = var.network
    fixed_ip_v4 = each.value.ip
  }
}
