output "admin_ws_public_ip" {
  value = openstack_networking_floatingip_v2.abm-ws.address
}
