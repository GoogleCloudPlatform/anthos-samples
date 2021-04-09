terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.58.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.58.0"
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
  vm_names                   = concat(local.admin_vm_names, local.controlplane_vm_names, local.worker_vm_names)
  admin_vm_names             = [for vmName in var.instance_names.admin : join("-", [var.hostname_prefix, vmName])]
  controlplane_vm_names      = [for vmName in var.instance_names.controlplane : join("-", [var.hostname_prefix, vmName])]
  worker_vm_names            = [for vmName in var.instance_names.worker : join("-", [var.hostname_prefix, vmName])]
  controlplane_vxlan_ips     = [for name in local.controlplane_vm_names : local.vm_vxlan_ip[name]]
  worker_vxlan_ips           = [for name in local.worker_vm_names : local.vm_vxlan_ip[name]]
  admin_vm_hostnames         = [for vm in module.admin_vm_hosts.vm_info : vm.hostname]
  vm_vxlan_ip                = { for idx, vmName in local.vm_names : vmName => "10.200.0.${idx + 2}" }
  vmHostnameToVmName         = { for vmName in local.vm_names : "${vmName}-001" => vmName }
  cluster_yaml_file          = "${path.module}/resources/.${var.abm_cluster_id}.yaml"
  cluster_yaml_template_file = "${path.module}/resources/anthos_gce_cluster.tpl"
  init_script                = "${path.module}/resources/init.sh"
  vm_hostnames_str           = join("|", local.vm_hostnames)
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
  version                     = "10.2.0"
  project_id                  = var.project_id
  activate_apis               = var.primary_apis
  disable_services_on_destroy = false
}

module "enable_google_apis_secondary" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "10.2.0"
  # fetched from previous module to explicitely express dependency
  project_id                  = module.enable_google_apis_primary.project_id
  depends_on                  = [module.enable_google_apis_primary]
  activate_apis               = var.secondary_apis
  disable_services_on_destroy = false
}

module "create_service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 3.0"
  # fetched from previous module to explicitely express dependency
  project_id = module.enable_google_apis_secondary.project_id
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  names         = ["baremetal-gcr"]
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
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  # fetched from previous module to explicitely express dependency
  project_id           = module.enable_google_apis_secondary.project_id
  region               = var.region          # --zone=${ZONE}
  service_account      = var.service_account # --scopes cloud-platform
  source_image_family  = var.image_family    # --image-family=ubuntu-2004-lts
  source_image_project = var.image_project   # --image-project=ubuntu-os-cloud
  machine_type         = var.machine_type    # --machine-type $MACHINE_TYPE
  disk_size_gb         = var.boot_disk_size  # --boot-disk-size 200G
  disk_type            = var.boot_disk_type  # --boot-disk-type pd-ssd
  can_ip_forward       = true                # --can-ip-forward
  network              = var.network         # --network default
  tags                 = var.tags            # --tags http-server,https-server
  # TODO:: Unavailable as of now
  # min_cpu_platform = var.min_cpu_platform # --min-cpu-platform "Intel Haswell"
}

module "admin_vm_hosts" {
  source = "./modules/vm"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  hostname_prefix   = var.hostname_prefix
  region            = var.region
  network           = var.network
  vm_names          = local.admin_vm_names
  instance_template = module.instance_template.self_link
}

module "controlplane_vm_hosts" {
  source = "./modules/vm"
  depends_on = [
    module.enable_google_apis_primary,
    module.enable_google_apis_secondary
  ]
  hostname_prefix   = var.hostname_prefix
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
  hostname_prefix   = var.hostname_prefix
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

module "init_hosts" {
  source            = "./modules/init"
  for_each          = toset(local.vm_hostnames)
  project_id        = var.project_id
  zone              = var.zone
  hostname          = each.value
  credentials_file  = var.credentials_file
  publicIp          = local.publicIps[each.value]
  hostnames         = local.vm_hostnames_str
  internalIps       = local.vm_internal_ips
  init_script       = local.init_script
  init_script_args  = "${var.zone} ${contains(local.admin_vm_hostnames, each.value)} ${local.vm_vxlan_ip[local.vmHostnameToVmName[each.value]]}"
  cluster_yaml_path = local.cluster_yaml_file
}
