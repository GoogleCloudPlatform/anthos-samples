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

locals {
  abm_on_gce_module_path = "../anthos-bm-gcp-terraform"
  apigee_resources       = "./resources"
  abm_on_gce_resources   = "${local.abm_on_gce_module_path}/resources"
  apigee_script          = "${local.apigee_resources}/install_apigee.sh"
  gce_home_dir           = "/home/${var.username}"
}

module "install_abm_on_gce" {
  source                 = "../anthos-bm-gcp-terraform"
  project_id             = var.project_id
  credentials_file       = var.credentials_file
  region                 = var.region
  zone                   = var.zone
  gcp_login_accounts     = var.gcp_login_accounts
  gce_vm_service_account = var.gce_vm_service_account
  username               = var.username
  mode                   = var.mode
  resources_path         = local.abm_on_gce_resources
  as_sub_module          = true
  abm_cluster_id         = "apigee-cluster"
  machine_type           = "n1-standard-8"
  instance_count = {
    "controlplane" : 3
    "worker" : 2
  }
  secondary_apis = [
    "anthos.googleapis.com",
    "anthosaudit.googleapis.com",
    "anthosgke.googleapis.com",
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "file.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "meshca.googleapis.com",
    "meshconfig.googleapis.com",
    "meshtelemetry.googleapis.com",
    "monitoring.googleapis.com",
    "opsconfigmonitoring.googleapis.com",
    "pubsub.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "sts.googleapis.com"
  ]
}

resource "null_resource" "exec_init_script" {
  connection {
    type        = "ssh"
    user        = var.username
    host        = module.install_abm_on_gce.admin_workstation_ip
    private_key = file(module.install_abm_on_gce.admin_workstation_ssh_key)
  }

  provisioner "file" {
    source      = local.apigee_script
    destination = "${local.gce_home_dir}/install_apigee.sh"
  }

  provisioner "file" {
    source      = var.credentials_file
    destination = "${local.gce_home_dir}/apigee-sa.json"
  }

  provisioner "remote-exec" {
    inline = ["gcloud auth activate-service-account --key-file ${local.gce_home_dir}/apigee-sa.json"]
  }

  provisioner "remote-exec" {
    inline = ["chmod 0550 ${local.gce_home_dir}/install_apigee.sh"]
  }
}
