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
  source    = "../external-ip"
  is_global = true
  ip_names  = [var.ip_name]
}

resource "google_compute_network_endpoint_group" "lb-neg" {
  name                  = "${var.name_prefix}-lb-neg"
  project               = var.project
  zone                  = var.zone
  network               = var.network
  network_endpoint_type = "GCE_VM_IP_PORT"
}

resource "google_compute_network_endpoint" "lb-network-endpoint" {
  project                = var.project
  zone                   = var.zone
  network_endpoint_group = google_compute_network_endpoint_group.lb-neg.name

  for_each = {
    for index, vm in var.lb_endpoint_instances : vm.name => vm
  }
  instance   = each.value.name
  port       = each.value.port
  ip_address = each.value.ip
}

resource "google_compute_health_check" "lb-health-check" {
  name              = "${var.name_prefix}-lb-health-check"
  project           = var.project
  healthy_threshold = 1

  dynamic "tcp_health_check" {
    for_each = var.type == "ingresslb" ? [1] : []
    content {
      port_specification = "USE_SERVING_PORT"
    }
  }

  dynamic "https_health_check" {
    for_each = var.type == "controlplanelb" ? [1] : []
    content {
      request_path = var.health_check_path
      port         = var.health_check_port
    }
  }
}

resource "google_compute_backend_service" "lb-backend" {
  name          = "${var.name_prefix}-lb-backend"
  project       = var.project
  protocol      = var.backend_protocol
  health_checks = [google_compute_health_check.lb-health-check.id]

  dynamic "backend" {
    for_each = var.type == "controlplanelb" ? [1] : []
    content {
      group           = google_compute_network_endpoint_group.lb-neg.id
      balancing_mode  = "CONNECTION"
      max_connections = 200
    }
  }

  dynamic "backend" {
    for_each = var.type == "ingresslb" ? [1] : []
    content {
      group          = google_compute_network_endpoint_group.lb-neg.id
      balancing_mode = "RATE"
      max_rate       = 1000
    }
  }
}

resource "google_compute_url_map" "ingress-lb-urlmap" {
  count           = var.type == "ingresslb" ? 1 : 0
  name            = "${var.name_prefix}-ingress-lb-urlmap"
  project         = var.project
  default_service = google_compute_backend_service.lb-backend.id
}

resource "google_compute_target_http_proxy" "lb-target-http-proxy" {
  count   = var.type == "ingresslb" ? 1 : 0
  name    = "${var.name_prefix}-lb-http-proxy"
  project = var.project
  url_map = google_compute_url_map.ingress-lb-urlmap[0].id
}

resource "google_compute_target_tcp_proxy" "lb-target-tcp-proxy" {
  count           = var.type == "controlplanelb" ? 1 : 0
  name            = "${var.name_prefix}-lb-tcp-proxy"
  project         = var.project
  backend_service = google_compute_backend_service.lb-backend.id
}

resource "google_compute_global_forwarding_rule" "lb-forwarding-rule" {
  name        = "${var.name_prefix}-lb-forwarding-rule"
  project     = var.project
  ip_protocol = "TCP"
  port_range  = join(",", var.forwarding_rule_ports)
  ip_address  = module.public_ip.ips[var.ip_name].id
  target      = var.type == "controlplanelb" ? google_compute_target_tcp_proxy.lb-target-tcp-proxy[0].id : google_compute_target_http_proxy.lb-target-http-proxy[0].id
}
