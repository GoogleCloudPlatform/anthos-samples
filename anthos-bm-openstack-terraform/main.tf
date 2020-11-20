provider "openstack" {
  user_name     = var.os_user_name
  tenant_name   = var.os_tenant_name
  password      = var.os_password
  auth_url      = var.os_auth_url
  region        = var.os_region
  endpoint_type = var.os_endpoint_type
  use_octavia   = true
}

resource "openstack_networking_router_v2" "abm" {
  name                = "abm"
  admin_state_up      = true
  external_network_id = var.external_network_id
}

resource "openstack_networking_network_v2" "abm" {
  name           = "abm"
  admin_state_up = "true"
  mtu            = 1400
}

resource "openstack_networking_subnet_v2" "abm-private" {
  name            = "abm-private"
  network_id      = openstack_networking_network_v2.abm.id
  cidr            = "10.200.0.0/24"
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
  allocation_pool {
    start = "10.200.0.3"
    end   = "10.200.0.100"
  }
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "abm-interface-1" {
  router_id = openstack_networking_router_v2.abm.id
  subnet_id = openstack_networking_subnet_v2.abm-private.id
}

resource "openstack_lb_loadbalancer_v2" "cp-lb" {
  name          = "cp-lb"
  vip_subnet_id = openstack_networking_subnet_v2.abm-private.id
  vip_address   = "10.200.0.101"
}

resource "openstack_lb_listener_v2" "cp-lb" {
  protocol        = "HTTPS"
  protocol_port   = 443
  loadbalancer_id = openstack_lb_loadbalancer_v2.cp-lb.id
}

resource "openstack_lb_pool_v2" "cp-lb" {
  protocol    = "HTTPS"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.cp-lb.id
}

resource "openstack_lb_monitor_v2" "cp-lb" {
  pool_id     = openstack_lb_pool_v2.cp-lb.id
  type        = "HTTPS"
  delay       = 20
  timeout     = 10
  max_retries = 5
  url_path    = "/readyz"
}

resource "openstack_lb_member_v2" "cp-lb-cp1" {
  pool_id       = openstack_lb_pool_v2.cp-lb.id
  address       = "10.200.0.11"
  protocol_port = 6444
}
resource "openstack_networking_floatingip_v2" "abm-cp-lb" {
  pool = "public"
}

resource "openstack_networking_floatingip_associate_v2" "abm-cp-lb" {
  floating_ip = openstack_networking_floatingip_v2.abm-cp-lb.address
  port_id     = openstack_lb_loadbalancer_v2.cp-lb.vip_port_id
}

resource "openstack_networking_floatingip_v2" "abm-ws" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "abm-ws" {
  floating_ip = openstack_networking_floatingip_v2.abm-ws.address
  instance_id = openstack_compute_instance_v2.abm-ws.id
}

resource "openstack_compute_secgroup_v2" "basic-access" {
  name        = "basic-access"
  description = "allow 443,SSH and icmp"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "tls_private_key" "abm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.yaml")}"
  vars = {
    private_key = tls_private_key.abm.private_key_pem,
    public_key  = tls_private_key.abm.public_key_openssh
  }
}

resource "openstack_compute_instance_v2" "abm-ws" {
  name            = "abm-ws"
  image_name      = "ubuntu-1804"
  flavor_name     = "m1.xlarge"
  key_pair        = "mykey"
  security_groups = ["default", openstack_compute_secgroup_v2.basic-access.name]
  user_data       = data.template_file.cloud-config.rendered
  network {
    uuid        = openstack_networking_network_v2.abm.id
    fixed_ip_v4 = "10.200.0.10"
  }
}

resource "openstack_compute_instance_v2" "abm-cp1" {
  name            = "abm-cp1"
  image_name      = "ubuntu-1804"
  flavor_name     = "m1.xlarge"
  key_pair        = "mykey"
  user_data       = data.template_file.cloud-config.rendered
  security_groups = ["default", openstack_compute_secgroup_v2.basic-access.name]
  network {
    uuid        = openstack_networking_network_v2.abm.id
    fixed_ip_v4 = "10.200.0.11"
  }
}

resource "openstack_compute_instance_v2" "abm-w1" {
  name            = "abm-w1"
  image_name      = "ubuntu-1804"
  flavor_name     = "m1.xlarge"
  key_pair        = "mykey"
  security_groups = ["default", openstack_compute_secgroup_v2.basic-access.name]
  user_data       = data.template_file.cloud-config.rendered
  network {
    uuid        = openstack_networking_network_v2.abm.id
    fixed_ip_v4 = "10.200.0.12"
  }
}
