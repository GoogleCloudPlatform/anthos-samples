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
  init_script_logfile_name            = "init.log"
  vm_name_template                    = "%s-abm-%s%d"
  gpu_enabled                         = var.gpu.type != ""
  admin_vm_name                       = [format(local.vm_name_template, var.abm_cluster_id, "ws", 0)]
  vm_names                            = concat(local.admin_vm_name, local.controlplane_vm_names, local.worker_vm_names)
  controlplane_vm_names               = [for i in range(var.instance_count.controlplane) : format(local.vm_name_template, var.abm_cluster_id, "cp", i + 1)]
  worker_vm_names                     = [for i in range(var.instance_count.worker) : format(local.vm_name_template, var.abm_cluster_id, "w", i + 1)]
  controlplane_vxlan_ips              = [for name in local.controlplane_vm_names : local.vm_vxlan_ip[name]]
  worker_vxlan_ips                    = [for name in local.worker_vm_names : local.vm_vxlan_ip[name]]
  controlplane_internal_ips           = [for vm in module.controlplane_vm_hosts.vm_info : vm.internalIp]
  worker_internal_ips                 = [for vm in module.worker_vm_hosts.vm_info : vm.internalIp]
  admin_vm_hostnames                  = [for vm in module.admin_vm_hosts.vm_info : vm.hostname]
  controlplane_vm_hostnames           = [for vm in module.controlplane_vm_hosts.vm_info : vm.hostname]
  vm_vxlan_ip                         = { for idx, vmName in local.vm_names : vmName => format("10.200.0.%d", idx + 2) }
  vmHostnameToVmName                  = { for vmName in local.vm_names : "${vmName}-001" => vmName }
  public_key_file_path_template       = "${var.resources_path}/.temp/%s/ssh-key.pub"
  private_key_file_path_template      = "${var.resources_path}/.temp/%s/ssh-key.priv"
  init_script_vars_file_path_template = "${var.resources_path}/.temp/%s/init.vars"
  cluster_yaml_file                   = "${var.resources_path}/.temp/.${var.abm_cluster_id}.yaml"
  cluster_yaml_template_file          = "${var.resources_path}/templates/anthos_gce_cluster.tpl"
  nfs_yaml_template_file              = "${var.resources_path}/templates/nfs-csi.tpl"
  cluster_yaml_manuallb_template_file = "${var.resources_path}/templates/manuallb_cluster.tpl"
  init_script_vars_file               = "${var.resources_path}/templates/init.vars.tpl"
  init_script                         = "${var.resources_path}/init_vm.sh"
  init_check_script                   = "${var.resources_path}/run_initialization_checks.sh"
  install_abm_script                  = "${var.resources_path}/install_abm.sh"
  login_script                        = "${var.resources_path}/login.sh"
  firewall_rule_name                  = "${var.abm_cluster_id}-allow-lb-traffic-rule"
  nfs_yaml_file                       = "${var.resources_path}/.temp/.nfs-csi.yaml"
  terraform_sa_path                   = "/home/${var.username}/terraform-sa.json"
  firewall_rule_ports                 = [6444, 443]
  firewall_rule_port_str              = join(",", [for port in local.firewall_rule_ports : "tcp:${port}"])
  vm_hostnames_str                    = join("|", local.vm_hostnames)
  controlplan_vm_hostnames_str        = join("|", local.controlplane_vm_hostnames)
  admin_vm_public_ip                  = [for vm in module.admin_vm_hosts.vm_info : vm.externalIp][0]
  vm_hostnames = concat(
    local.admin_vm_hostnames,
    local.controlplane_vm_hostnames,
    [for vm in module.worker_vm_hosts.vm_info : vm.hostname]
  )
  vm_internal_ips = join("|", concat(
    [for vm in module.admin_vm_hosts.vm_info : vm.internalIp],
    local.controlplane_internal_ips,
    local.worker_internal_ips)
  )
  publicIps = merge(
    { for vm in module.admin_vm_hosts.vm_info : vm.hostname => vm.externalIp },
    { for vm in module.controlplane_vm_hosts.vm_info : vm.hostname => vm.externalIp },
    { for vm in module.worker_vm_hosts.vm_info : vm.hostname => vm.externalIp }
  )
}

module "enable_google_apis_primary" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 14.0"
  project_id                  = var.project_id
  activate_apis               = var.primary_apis
  disable_services_on_destroy = false
}

module "enable_google_apis_secondary" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.0"
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
    "${var.project_id}=>roles/opsconfigmonitoring.resourceMetadata.writer",
  ]
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 8.0"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  # fetched from previous module to explicitely express dependency
  project_id                   = module.enable_google_apis_secondary.project_id
  region                       = var.region                       # --zone=${ZONE}
  source_image                 = var.image                        # --image=ubuntu-2004-focal-v20210429
  source_image_family          = var.image_family                 # --image-family=ubuntu-2004-lts
  source_image_project         = var.image_project                # --image-project=ubuntu-os-cloud
  machine_type                 = var.machine_type                 # --machine-type $MACHINE_TYPE
  disk_size_gb                 = var.boot_disk_size               # --boot-disk-size 200G
  disk_type                    = var.boot_disk_type               # --boot-disk-type pd-ssd
  network                      = var.network                      # --network default
  tags                         = var.tags                         # --tags http-server,https-server
  min_cpu_platform             = var.min_cpu_platform             # --min-cpu-platform "Intel Haswell"
  can_ip_forward               = true                             # --can-ip-forward
  enable_nested_virtualization = var.enable_nested_virtualization # --enable-nested-virtualization
  # Disable oslogin explicitly since we rely on metadata based ssh-key (issues/70).
  metadata = {
    enable-oslogin = "false"
  }
  service_account = null
  gpu = !local.gpu_enabled ? null : {
    type  = var.gpu.type
    count = var.gpu.count
  }
}

module "admin_vm_hosts" {
  source = "./modules/vm"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  region            = var.region
  zone              = var.zone
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
  zone              = var.zone
  network           = var.network
  vm_names          = local.controlplane_vm_names
  instance_template = module.instance_template.self_link

  lifecycle {
    replace_triggered_by = [
      local_file.init_args_file
    ]
  }
}

module "worker_vm_hosts" {
  source = "./modules/vm"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  region            = var.region
  zone              = var.zone
  network           = var.network
  vm_names          = local.worker_vm_names
  instance_template = module.instance_template.self_link

  lifecycle {
    replace_triggered_by = [
      local_file.init_args_file
    ]
  }
}

module "configure_controlplane_lb" {
  source = "./modules/loadbalancer"
  count  = var.mode == "manuallb" ? 1 : 0
  depends_on = [
    module.admin_vm_hosts,
    module.controlplane_vm_hosts,
    module.worker_vm_hosts
  ]
  type                  = "controlplanelb"
  project               = var.project_id
  region                = var.region
  zone                  = var.zone
  name_prefix           = "${var.abm_cluster_id}-cp"
  ip_name               = "${var.abm_cluster_id}-cp-public-ip"
  health_check_path     = "/readyz"
  health_check_port     = 6444
  backend_protocol      = "TCP"
  forwarding_rule_ports = [443]
  lb_endpoint_instances = [
    for vm in module.controlplane_vm_hosts.vm_info : {
      name = vm.hostname
      ip   = vm.internalIp
      port = 6444
    }
  ]
}

module "configure_ingress_lb" {
  source = "./modules/loadbalancer"
  count  = var.mode == "manuallb" ? 1 : 0
  depends_on = [
    module.admin_vm_hosts,
    module.controlplane_vm_hosts,
    module.worker_vm_hosts
  ]
  type                  = "ingresslb"
  project               = var.project_id
  region                = var.region
  zone                  = var.zone
  name_prefix           = "${var.abm_cluster_id}-ing"
  ip_name               = "${var.abm_cluster_id}-ing-public-ip"
  backend_protocol      = "HTTP"
  forwarding_rule_ports = [80]
}

resource "google_compute_firewall" "lb-firewall-rule" {
  name = local.firewall_rule_name
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  network       = var.network
  target_tags   = var.tags
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = local.firewall_rule_ports
  }
}

// Generate the Anthos bare metal cluster yaml file using the template for
// bundled load balancer setup. This resource is created only if the mode is
// NOT 'manuallb' (i.e. setup or install)
resource "local_file" "cluster_yaml_bundledlb" {
  depends_on = [
    module.controlplane_vm_hosts,
    module.worker_vm_hosts
  ]
  count    = var.mode == "manuallb" ? 0 : 1
  filename = local.cluster_yaml_file
  content = templatefile(local.cluster_yaml_template_file, {
    clusterId       = var.abm_cluster_id,
    projectId       = var.project_id,
    gcp_accounts    = var.gcp_login_accounts,
    controlPlaneIps = local.controlplane_vxlan_ips,
    workerNodeIps   = local.worker_vxlan_ips
    abmVersion      = var.abm_version
  })
}

// Generate the Anthos bare metal cluster yaml file using the template for
// manual load balancer setup. This resource is created only if the mode is
// 'manuallb'
resource "local_file" "cluster_yaml_manuallb" {
  depends_on = [
    module.controlplane_vm_hosts,
    module.worker_vm_hosts
  ]
  count    = var.mode == "manuallb" ? 1 : 0
  filename = local.cluster_yaml_file
  content = templatefile(local.cluster_yaml_manuallb_template_file, {
    clusterId       = var.abm_cluster_id,
    projectId       = var.project_id,
    gcp_accounts    = var.gcp_login_accounts,
    controlPlaneIps = local.controlplane_internal_ips,
    workerNodeIps   = local.worker_internal_ips,
    controlPlaneVIP = module.configure_controlplane_lb[0].public_ip,
    ingressVIP      = module.configure_ingress_lb[0].public_ip
    abmVersion      = var.abm_version
  })
}

resource "google_filestore_instance" "cluster-abm-nfs" {
  count = var.nfs_server ? 1 : 0
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  name     = "${substr(var.abm_cluster_id, 0, min(12, length(var.abm_cluster_id)))}-nfs"
  location = var.zone
  tier     = "STANDARD"

  file_shares {
    capacity_gb = 1024
    name        = "${var.abm_cluster_id}_fs"
  }

  networks {
    network = var.network
    modes   = ["MODE_IPV4"]
  }
}

// Generate the Anthos bare metal nfs yaml file using the template.
// This file is only used when the `nfs_server` variable is set to true.
resource "local_file" "nfs_yaml" {
  depends_on = [
    module.controlplane_vm_hosts,
    module.worker_vm_hosts
  ]
  filename = local.nfs_yaml_file
  content = templatefile(local.nfs_yaml_template_file, {
    nfs_server = var.nfs_server ? google_filestore_instance.cluster-abm-nfs[0].networks[0].ip_addresses[0] : ""
    nfs_share  = var.nfs_server ? google_filestore_instance.cluster-abm-nfs[0].file_shares[0].name : ""
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
    zone              = var.zone,
    clusterId         = var.abm_cluster_id,
    isAdminVm         = contains(local.admin_vm_hostnames, each.value),
    vxLanIp           = local.vm_vxlan_ip[local.vmHostnameToVmName[each.value]],
    serviceAccount    = var.anthos_service_account_name,
    terraformSAccount = local.terraform_sa_path,
    hostnames         = local.vm_hostnames_str,
    controlplaneVms   = local.controlplan_vm_hostnames_str,
    vmInternalIps     = local.vm_internal_ips,
    logFile           = local.init_script_logfile_name
    firewallRuleName  = local.firewall_rule_name
    firewallPorts     = local.firewall_rule_port_str
    installMode       = var.mode
    ingressNeg        = var.mode == "manuallb" ? module.configure_ingress_lb[0].neg_name : ""
    ingressLbIp       = var.mode == "manuallb" ? module.configure_ingress_lb[0].public_ip : ""
    nfsServer         = var.nfs_server
    abmVersion        = var.abm_version
  })
}

module "init_hosts" {
  source = "./modules/init"
  module_depends_on = [
    local_file.init_args_file[each.key],
    local_file.nfs_yaml
  ]
  for_each               = toset(local.vm_hostnames)
  project_id             = var.project_id
  zone                   = var.zone
  hostname               = each.value
  username               = var.username
  credentials_file       = var.credentials_file
  resources_path         = var.resources_path
  publicIp               = local.publicIps[each.value]
  init_script            = local.init_script
  init_check_script      = local.init_check_script
  install_abm_script     = local.install_abm_script
  login_script           = local.login_script
  init_logs              = local.init_script_logfile_name
  pub_key_path_template  = local.public_key_file_path_template
  priv_key_path_template = local.private_key_file_path_template
  init_vars_file         = format(local.init_script_vars_file_path_template, each.value)
  cluster_yaml_path      = local.cluster_yaml_file
  nfs_yaml_path          = local.nfs_yaml_file
  terraform_sa_path      = local.terraform_sa_path
}

module "install_abm" {
  source = "./modules/install"
  depends_on = [
    module.init_hosts,
    module.configure_ingress_lb,
    module.configure_controlplane_lb
  ]
  count                = var.mode == "install" || var.mode == "manuallb" ? 1 : 0
  username             = var.username
  publicIp             = local.publicIps[local.admin_vm_hostnames[0]]
  ssh_private_key_file = format(local.private_key_file_path_template, local.admin_vm_hostnames[0])
}

module "gke_hub_membership" {
  source                = "terraform-google-modules/gcloud/google"
  version               = "~> 3.1"
  platform              = "linux"
  create_cmd_entrypoint = "echo"
  create_cmd_body       = "GKE hub membership is created by bmctl create cluster"
  destroy_cmd_body      = "container hub memberships delete --quiet --project ${var.project_id} ${var.abm_cluster_id} --verbosity=none || true"
}
