resource "openstack_compute_instance_v2" "openstack_instance" {
  for_each        = toset(var.vm_names)
  name            = each.value
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = var.key
  security_groups = var.security_groups
  user_data       = var.user_data
  network {
    uuid        = var.network
    fixed_ip_v4 = var.ip
  }
}
