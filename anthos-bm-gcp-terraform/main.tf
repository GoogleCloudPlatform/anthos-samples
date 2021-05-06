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

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.66.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.66.1"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.credentials_file)
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.credentials_file)
}

locals {
  init_script_logfile_name            = "init.log"
  vm_name_template                    = "abm-%s%d"
  admin_vm_name                       = [format(local.vm_name_template, "ws", 0)]
  vm_names                            = concat(local.admin_vm_name, local.controlplane_vm_names, local.worker_vm_names)
  controlplane_vm_names               = [for i in range(var.instance_count.controlplane) : format(local.vm_name_template, "cp", i + 1)]
  worker_vm_names                     = [for i in range(var.instance_count.worker) : format(local.vm_name_template, "w", i + 1)]
  controlplane_vxlan_ips              = [for name in local.controlplane_vm_names : local.vm_vxlan_ip[name]]
  worker_vxlan_ips                    = [for name in local.worker_vm_names : local.vm_vxlan_ip[name]]
  admin_vm_hostnames                  = [for vm in module.admin_vm_hosts.vm_info : vm.hostname]
  vm_vxlan_ip                         = { for idx, vmName in local.vm_names : vmName => format("10.200.0.%d", idx + 2) }
  vmHostnameToVmName                  = { for vmName in local.vm_names : "${vmName}-001" => vmName }
  public_key_file_path_template       = "${path.module}/resources/.temp/%s/ssh-key.pub"
  private_key_file_path_template      = "${path.module}/resources/.temp/%s/ssh-key.priv"
  init_script_vars_file_path_template = "${path.module}/resources/.temp/%s/init.vars"
  cluster_yaml_file                   = "${path.module}/resources/.temp/.${var.abm_cluster_id}.yaml"
  cluster_yaml_template_file          = "${path.module}/resources/anthos_gce_cluster.tpl"
  init_script_vars_file               = "${path.module}/resources/init.vars.tpl"
  init_script                         = "${path.module}/resources/init.sh"
  preflight_script                    = "${path.module}/resources/preflights.sh"
  vm_hostnames_str                    = join("|", local.vm_hostnames)
  vm_hostnames = concat(
    local.admin_vm_hostnames,
    [for vm in module.controlplane_vm_hosts.vm_info : vm.hostname],
    [for vm in module.worker_vm_hosts.vm_info : vm.hostname]
  )
  vm_internal_ips = join("|", concat(
    [for vm in module.admin_vm_hosts.vm_info : vm.internalIp],
    [for vm in module.controlplane_vm_hosts.vm_info : vm.internalIp],
    [for vm in module.worker_vm_hosts.vm_info : vm.internalIp])
  )
  publicIps = merge(
    { for vm in module.admin_vm_hosts.vm_info : vm.hostname => vm.externalIp },
    { for vm in module.controlplane_vm_hosts.vm_info : vm.hostname => vm.externalIp },
    { for vm in module.worker_vm_hosts.vm_info : vm.hostname => vm.externalIp }
  )
}

module "enable_google_apis_primary" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "10.3.2"
  project_id                  = var.project_id
  activate_apis               = var.primary_apis
  disable_services_on_destroy = false
}

module "enable_google_apis_secondary" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "10.3.2"
  # fetched from previous module to explicitely express dependency
  project_id                  = module.enable_google_apis_primary.project_id
  depends_on                  = [module.enable_google_apis_primary]
  activate_apis               = var.secondary_apis
  disable_services_on_destroy = false
}

module "create_service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"
  # fetched from previous module to explicitely express dependency
  project_id = module.enable_google_apis_secondary.project_id
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  names         = [var.anthos_service_account_name]
  generate_keys = true
  project_roles = [
    "${var.project_id}=>roles/gkehub.connect",
    "${var.project_id}=>roles/gkehub.admin",
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
    "${var.project_id}=>roles/monitoring.dashboardEditor",
    "${var.project_id}=>roles/stackdriver.resourceMetadata.writer",
  ]
}

module "instance_template" {
  source = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 6.3.0"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  # fetched from previous module to explicitely express dependency
  project_id           = module.enable_google_apis_secondary.project_id
  region               = var.region           # --zone=${ZONE}
  source_image_family  = var.image_family     # --image-family=ubuntu-2004-lts
  source_image_project = var.image_project    # --image-project=ubuntu-os-cloud
  machine_type         = var.machine_type     # --machine-type $MACHINE_TYPE
  disk_size_gb         = var.boot_disk_size   # --boot-disk-size 200G
  disk_type            = var.boot_disk_type   # --boot-disk-type pd-ssd
  network              = var.network          # --network default
  tags                 = var.tags             # --tags http-server,https-server
  can_ip_forward       = true                 # --can-ip-forward
  min_cpu_platform     = var.min_cpu_platform # --min-cpu-platform "Intel Haswell"
  service_account = {
    email  = ""
    scopes = var.access_scopes # --scopes cloud-platform
  }
}

module "admin_vm_hosts" {
  source = "./modules/vm"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  region            = var.region
  network           = var.network
  vm_names          = local.admin_vm_name
  instance_template = module.instance_template.self_link
}

module "controlplane_vm_hosts" {
  source = "./modules/vm"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  region            = var.region
  network           = var.network
  vm_names          = local.controlplane_vm_names
  instance_template = module.instance_template.self_link
}

module "worker_vm_hosts" {
  source = "./modules/vm"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  region            = var.region
  network           = var.network
  vm_names          = local.worker_vm_names
  instance_template = module.instance_template.self_link
}

resource "local_file" "cluster_yaml" {
  depends_on = [
    module.controlplane_vm_hosts,
    module.worker_vm_hosts
  ]
  filename = local.cluster_yaml_file
  content = templatefile(local.cluster_yaml_template_file, {
    clusterId       = var.abm_cluster_id,
    projectId       = var.project_id,
    controlPlaneIps = local.controlplane_vxlan_ips,
    workerNodeIps   = local.worker_vxlan_ips
  })
}

resource "local_file" "init_args_file" {
  depends_on = [
    module.controlplane_vm_hosts,
    module.worker_vm_hosts
  ]
  for_each = toset(local.vm_hostnames)
  filename = format(local.init_script_vars_file_path_template, each.value)
  content = templatefile(local.init_script_vars_file, {
    zone           = var.zone,
    isAdminVm      = contains(local.admin_vm_hostnames, each.value),
    vxLanIp        = local.vm_vxlan_ip[local.vmHostnameToVmName[each.value]],
    serviceAccount = var.anthos_service_account_name,
    hostnames      = local.vm_hostnames_str,
    vmInternalIps  = local.vm_internal_ips,
    logFile        = local.init_script_logfile_name
  })
}

module "init_hosts" {
  source                 = "./modules/init"
  for_each               = toset(local.vm_hostnames)
  project_id             = var.project_id
  zone                   = var.zone
  hostname               = each.value
  username               = var.username
  credentials_file       = var.credentials_file
  publicIp               = local.publicIps[each.value]
  init_script            = local.init_script
  preflight_script       = local.preflight_script
  init_logs              = local.init_script_logfile_name
  pub_key_path_template  = local.public_key_file_path_template
  priv_key_path_template = local.private_key_file_path_template
  init_vars_file         = format(local.init_script_vars_file_path_template, each.value)
  cluster_yaml_path      = local.cluster_yaml_file
}
