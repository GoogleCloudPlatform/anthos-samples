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
  ssh_pub_key_template_file = "${var.resources_path}/ssh-keys.tpl"
  ssh_pub_key_file          = format(var.pub_key_path_template, var.hostname)
  ssh_private_key_file      = format(var.priv_key_path_template, var.hostname)
  cluster_yaml_file_name    = trimprefix(basename(var.cluster_yaml_path), ".")
  home_dir                  = "/home/${var.username}"
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "temp_ssh_pub_key_file" {
  filename        = local.ssh_pub_key_file
  file_permission = "0600"
  content = templatefile(
    local.ssh_pub_key_template_file, {
      username = var.username,
      ssh_key  = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
    }
  )
}

resource "local_file" "temp_ssh_priv_key_file" {
  filename        = local.ssh_private_key_file
  file_permission = "0600"
  content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
}

module "gcloud_add_ssh_key_metadata" {
  source                   = "terraform-google-modules/gcloud/google"
  version                  = "3.1.0"
  platform                 = "linux"
  service_account_key_file = var.credentials_file
  module_depends_on = [
    local_file.temp_ssh_pub_key_file,
    local_file.temp_ssh_priv_key_file
  ]

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<EOT
    compute instances add-metadata ${var.hostname}  \
    --project ${var.project_id}                                    \
    --zone ${var.zone}                                             \
    --metadata-from-file ssh-keys=${local.ssh_pub_key_file}
  EOT
}

resource "null_resource" "exec_init_script" {
  depends_on = [module.gcloud_add_ssh_key_metadata]
  connection {
    type        = "ssh"
    user        = var.username
    host        = var.publicIp
    private_key = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  }

  provisioner "file" {
    source      = var.cluster_yaml_path
    destination = "${local.home_dir}/${local.cluster_yaml_file_name}"
  }

  provisioner "file" {
    source      = var.init_vars_file
    destination = "${local.home_dir}/init.vars"
  }

  provisioner "file" {
    source      = var.init_script
    destination = "${local.home_dir}/init_vm.sh"
  }

  provisioner "file" {
    source      = var.init_check_script
    destination = "${local.home_dir}/run_initialization_checks.sh"
  }

  provisioner "file" {
    source      = var.install_abm_script
    destination = "${local.home_dir}/install_abm.sh"
  }

  provisioner "file" {
    source      = var.login_script
    destination = "${local.home_dir}/login.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 ${local.home_dir}/${local.cluster_yaml_file_name}",
      "chmod 0600 ${local.home_dir}/init.vars",
      "chmod 0100 ${local.home_dir}/init_vm.sh",
      "chmod 0100 ${local.home_dir}/run_initialization_checks.sh",
      "chmod 0550 ${local.home_dir}/install_abm.sh",
      "chmod 0550 ${local.home_dir}/login.sh"
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh                               \
      -o 'StrictHostKeyChecking no'     \
      -o 'UserKnownHostsFile /dev/null' \
      -o 'IdentitiesOnly yes'           \
      -F /dev/null                      \
      -i ${local.ssh_private_key_file}  \
      ${var.username}@${var.publicIp}   \
      'nohup sudo ${local.home_dir}/init_vm.sh > ${local.home_dir}/${var.init_logs} 2>&1 &'
    EOT
  }
}
