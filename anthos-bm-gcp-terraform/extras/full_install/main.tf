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

locals {}

module "gce_setup_for_abm" {
  source                 = "../../"
  project_id             = var.project_id
  region                 = var.region
  zone                   = var.zone
  credentials_file       = var.credentials_file
  abm_cluster_id         = var.abm_cluster_id
  resources_path         = var.resources_path
  machine_type           = var.machine_type
  instance_count         = var.instance_count
  gce_vm_service_account = var.gce_vm_service_account
  gpu                    = var.gpu
}

module "init_hosts" {
  source                 = "./install_abm"
  project_id             = var.project_id
  zone                   = var.zone
  hostname               = each.value
  username               = var.username
  credentials_file       = var.credentials_file
  resources_path         = var.resources_path
  publicIp               = local.publicIps[each.value]
  init_script            = local.init_script
  init_check_script      = local.init_check_script
  init_logs              = local.init_script_logfile_name
  pub_key_path_template  = local.public_key_file_path_template
  priv_key_path_template = local.private_key_file_path_template
  init_vars_file         = format(local.init_script_vars_file_path_template, each.value)
  cluster_yaml_path      = local.cluster_yaml_file
}
