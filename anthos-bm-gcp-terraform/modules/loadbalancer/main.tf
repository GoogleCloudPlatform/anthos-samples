/**
 * Copyright 2022 Google LLC
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

module "public_ip" {
  source   = "../external-ip"
  region   = var.region
  ip_names = [var.ip_name]
}

resource "google_compute_network_endpoint_group" "lb-neg" {
  name                  = "${var.name_prefix}-lb-neg"
  project               = var.project
  zone                  = var.zone
  network               = var.network
  network_endpoint_type = "GCE_VM_IP_PORT"
}

resource "google_compute_network_endpoint" "lb-network-endpoint" {
  count                  = var.mode == "controlplanelb" ? 1 : 0
  project                = var.project
  zone                   = var.zone
  network_endpoint_group = google_compute_network_endpoint_group.lb-neg.name

  for_each   = var.lb_endpoint_instances
  instance   = each.value.name
  port       = each.value.port
  ip_address = each.value.ip
}

resource "google_compute_https_health_check" "lb-l7-health-check" {
  count        = var.mode == "controlplanelb" ? 1 : 0
  name         = "${var.name_prefix}-lb-health-check"
  project      = var.project
  request_path = var.health_check_path
  port         = var.health_check_port
}

resource "google_compute_health_check" "lb-l4-health-check" {
  count   = var.mode == "ingresslb" ? 1 : 0
  name    = "${var.name_prefix}-lb-health-check"
  project = var.project
}

resource "google_compute_backend_service" "lb-backend" {
  name     = "${var.name_prefix}-lb-backend"
  project  = var.project
  protocol = var.backend_protocol
  health_checks = [
    var.mode == "controlplanelb" ?
    google_compute_https_health_check.lb-health-check.id :
    google_compute_health_check.lb-l4-health-check.id
  ]

  backend {
    for_each        = var.mode == "controlplanelb" ? [1] : []
    group           = google_compute_network_endpoint_group.lb-neg.id
    balancing_mode  = "CONNECTION"
    max_connections = 200
  }

  backend {
    for_each       = var.mode == "ingresslb" ? [1] : []
    group          = google_compute_network_endpoint_group.lb-neg.id
    balancing_mode = "RATE"
    max_rate       = 1000
  }
}

resource "google_compute_url_map" "ingress-lb-urlmap" {
  count           = var.mode == "ingresslb" ? 1 : 0
  name            = "abm-ingress-lb-urlmap"
  project         = var.project
  default_service = google_compute_backend_service.lb-backend.id
}

resource "google_compute_target_http_proxy" "lb-target-http-proxy" {
  count   = var.mode == "ingresslb" ? 1 : 0
  name    = "${var.name_prefix}-lb-http-proxy"
  project = var.project
  url_map = google_compute_url_map.ingress-lb-urlmap.id
}

resource "google_compute_target_tcp_proxy" "lb-target-tcp-proxy" {
  count           = var.mode == "controlplanelb" ? 1 : 0
  name            = "${var.name_prefix}-lb-tcp-proxy"
  project         = var.project
  backend_service = google_compute_backend_service.lb-backend.id
}

resource "google_compute_forwarding_rule" "lb-forwarding-rule" {
  name        = "${var.name_prefix}-lb-forwarding-rule"
  project     = var.project
  ip_protocol = "TCP"
  ports       = var.forwarding_rule_ports
  ip_address  = module.public_ip.ips[var.ip_name].address
  target      = var.mode == "controlplanelb" ? google_compute_target_tcp_proxy.lb-target-tcp-proxy.id : google_compute_target_http_proxy.lb-target-http-proxy.id
}

resource "google_compute_firewall" "lb-firewall-rule" {
  count       = var.create_firewall_rule ? 1 : 0
  name        = "${var.name_prefix}-lb-firewall-rule"
  network     = var.network
  target_tags = var.firewall_rule_target_tags
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = var.firewall_rule_allow_ports
  }
}
