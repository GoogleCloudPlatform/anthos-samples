/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  abm_name_template     = "abm-%s"
  subnet_cidr_prefix    = "10.200.0.%s"
  dns_servers           = ["8.8.8.8", "8.8.4.4"]
  vm_name_template      = "${local.abm_name_template}%d"
  cloud_config_path     = "${path.module}/cloud-config.yaml"
  subnet_cidr           = format(local.subnet_cidr_prefix, "0/24") // 10.200.0.0/24
  subnet_start_ip       = format(local.subnet_cidr_prefix, "3")    // 10.200.0.3
  subnet_end_ip         = format(local.subnet_cidr_prefix, "100")  // 10.200.0.100
  controlplane_lb_vip   = format(local.subnet_cidr_prefix, "101")  // 10.200.0.101
  router_name           = format(local.abm_name_template, "router")
  network_name          = format(local.abm_name_template, "network")
  subnetwork_name       = format(local.abm_name_template, "subnetwork")
  controlplane_lb_name  = format(local.abm_name_template, "cp-lb")
  admin_vm_names        = [format(local.vm_name_template, "ws", 0)]
  controlplane_vm_names = [for i in range(var.instance_count.controlplane) : format(local.vm_name_template, "cp", i + 1)]
  worker_vm_names       = [for i in range(var.instance_count.worker) : format(local.vm_name_template, "w", i + 1)]
  admin_ip_start        = 10
  controlplane_ip_start = local.admin_ip_start + length(local.admin_vm_names)
  worker_ip_start       = local.controlplane_ip_start + length(local.controlplane_vm_names)
  admin_vm_info = [
    for idx, vmName in local.admin_vm_names : {
      name : vmName,
      ip : format(local.subnet_cidr_prefix, local.admin_ip_start + idx)
    }
  ]
  controlplane_vm_info = [
    for idx, vmName in local.controlplane_vm_names : {
      name : vmName,
      ip : format(local.subnet_cidr_prefix, local.controlplane_ip_start + idx)
    }
  ]
  worker_vm_info = [
    for idx, vmName in local.worker_vm_names : {
      name : vmName,
      ip : format(local.subnet_cidr_prefix, local.worker_ip_start + idx)
    }
  ]
}

###############################################################################
# Create the OpenStack network setup for Anthos BareMetal hosts
# - OpenStack router
# - OpenStack network
# - OpenStack subnet
# - Roter interface on the subnet
###############################################################################
resource "openstack_networking_router_v2" "abm_network_router" {
  name                = local.router_name
  external_network_id = var.external_network_id
  admin_state_up      = true
}

resource "openstack_networking_network_v2" "abm_network" {
  name           = local.network_name
  mtu            = var.network_mtu
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "abm_subnetwork" {
  name            = local.subnetwork_name
  cidr            = local.subnet_cidr
  network_id      = openstack_networking_network_v2.abm_network.id
  dns_nameservers = local.dns_servers
  allocation_pool {
    start = local.subnet_start_ip
    end   = local.subnet_end_ip
  }
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "abm_interface_1" {
  router_id = openstack_networking_router_v2.abm_network_router.id
  subnet_id = openstack_networking_subnet_v2.abm_subnetwork.id
}

###############################################################################
# Create the control plane loadbalancer for the Anthos BareMetal setup
# - LoadBalancer (based on LBaaS v2, i.e: Octavia)
# - LoadBalancer Listener
# - LoadBalancer Pool
# - LoadBalancer Monitor
# - LoadBalancer Members (one each for controlplane nodes)
###############################################################################
resource "openstack_lb_loadbalancer_v2" "abm_cp_lb" {
  name          = local.controlplane_lb_name
  vip_address   = local.controlplane_lb_vip
  vip_subnet_id = openstack_networking_subnet_v2.abm_subnetwork.id
}

resource "openstack_lb_listener_v2" "abm_cp_lb_listener" {
  protocol        = "HTTPS"
  protocol_port   = 443
  loadbalancer_id = openstack_lb_loadbalancer_v2.abm_cp_lb.id
}

resource "openstack_lb_pool_v2" "abm_cp_lb_pool" {
  protocol    = "HTTPS"
  lb_method   = var.lb_method
  listener_id = openstack_lb_listener_v2.abm_cp_lb_listener.id
}

resource "openstack_lb_monitor_v2" "abm_cp_lb_monitor" {
  pool_id     = openstack_lb_pool_v2.abm_cp_lb_pool.id
  type        = "HTTPS"
  delay       = 5
  timeout     = 5
  max_retries = 5
  url_path    = "/readyz"
}

resource "openstack_lb_member_v2" "lb_membership_cp_nodes" {
  for_each      = { for index, vm in local.controlplane_vm_info : index => vm }
  pool_id       = openstack_lb_pool_v2.abm_cp_lb_pool.id
  address       = each.value.ip
  protocol_port = 6444
}

###############################################################################
# Create security groups for configuring access for the Anthos BareMeal hosts
# - Allow TCP port 443 for HTTPS traffic
# - Allow TCP port 22 for SSH traffic
# - Allow all ICMP traffic
###############################################################################
resource "openstack_compute_secgroup_v2" "basic_access" {
  name        = "basic_access"
  description = "Allow HTTPS(443), SSH(22) and ICMP"

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

###############################################################################
# Create public-private key pair for use by the Anthos BareMetal hosts
###############################################################################
resource "tls_private_key" "abm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

###############################################################################
# Generate the cloud-init configuration by filling in the templated details
# in the cloud-config file
###############################################################################
data "template_file" "cloud_config" {
  template = file(local.cloud_config_path)
  vars = {
    private_key = tls_private_key.abm_key.private_key_pem,
    public_key  = tls_private_key.abm_key.public_key_openssh
  }
}

###############################################################################
# Create the VMs for the Anthos BareMetal setup
# - 1 VM for the Admin workstation
# - VMs for the Controlplane based on the input variable 'instance_count'
# - VMs for the worker nodes based on the input variable 'instance_count'
###############################################################################
module "admin_vm_hosts" {
  source          = "./modules/vm"
  vm_info         = local.admin_vm_info
  image           = var.image
  flavor          = var.machine_type
  key             = var.ssh_key
  network         = openstack_networking_network_v2.abm_network.id
  user_data       = data.template_file.cloud_config.rendered
  security_groups = ["default", openstack_compute_secgroup_v2.basic_access.name]
}

module "cp_vm_hosts" {
  source          = "./modules/vm"
  vm_info         = local.controlplane_vm_info
  image           = var.image
  flavor          = var.machine_type
  key             = var.ssh_key
  network         = openstack_networking_network_v2.abm_network.id
  user_data       = data.template_file.cloud_config.rendered
  security_groups = ["default", openstack_compute_secgroup_v2.basic_access.name]
}

module "worker_vm_hosts" {
  source          = "./modules/vm"
  vm_info         = local.worker_vm_info
  image           = var.image
  flavor          = var.machine_type
  key             = var.ssh_key
  network         = openstack_networking_network_v2.abm_network.id
  user_data       = data.template_file.cloud_config.rendered
  security_groups = ["default", openstack_compute_secgroup_v2.basic_access.name]
}

###############################################################################
# Associate floating virtual IPs for the control plane and admin workstation
###############################################################################
resource "openstack_networking_floatingip_v2" "abm_ws_floatingip" {
  pool = "public"
}

resource "openstack_networking_floatingip_v2" "abm_cp_floatingip" {
  pool = "public"
}

resource "openstack_networking_floatingip_associate_v2" "abm_cp_ip_lb_association" {
  floating_ip = openstack_networking_floatingip_v2.abm_cp_floatingip.address
  port_id     = openstack_lb_loadbalancer_v2.abm_cp_lb.vip_port_id
}

resource "openstack_compute_floatingip_associate_v2" "abm_ws_ip_lb_association" {
  floating_ip = openstack_networking_floatingip_v2.abm_ws_floatingip.address
  instance_id = module.admin_vm_hosts.vm_ids[0]
}
