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

module "instance_template" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "~> 6.3.0"
  project_id           = var.project_id
  region               = var.region           # --zone=${ZONE}
  source_image         = var.image            # --image=ubuntu-2004-focal-v20210429
  source_image_family  = var.image_family     # --image-family=ubuntu-2004-lts
  source_image_project = var.image_project    # --image-project=ubuntu-os-cloud
  min_cpu_platform     = var.min_cpu_platform # --min-cpu-platform "Intel Haswell"
  machine_type         = var.machine_type     # --machine-type $MACHINE_TYPE
  disk_size_gb         = var.boot_disk_size   # --boot-disk-size 200G
  disk_type            = var.boot_disk_type   # --boot-disk-type pd-ssd
  network              = var.network          # --network default
  tags                 = var.tags             # --tags http-server,https-server
  can_ip_forward       = true                 # --can-ip-forward
  service_account = {
    email  = ""
    scopes = var.access_scopes # --scopes cloud-platform
  }
  gpu = !var.gpu_enabled ? null : {
    type  = var.gpu_machine_type
    count = var.gpu_count
  }
}
