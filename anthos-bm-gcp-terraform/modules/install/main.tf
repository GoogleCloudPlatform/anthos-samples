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
  home_dir = "/home/${var.username}"
}

resource "null_resource" "run_abm_installation" {
  connection {
    type        = "ssh"
    user        = var.username
    host        = var.publicIp
    private_key = file(var.ssh_private_key_file)
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh                               \
      -o 'StrictHostKeyChecking no'     \
      -o 'UserKnownHostsFile /dev/null' \
      -o 'IdentitiesOnly yes'           \
      -F /dev/null                      \
      -i ${var.ssh_private_key_file}  \
      ${var.username}@${var.publicIp}   \
      'nohup sudo ${local.home_dir}/install_abm.sh > ${local.home_dir}/install_abm.log 2>&1 &'
    EOT
  }
}
