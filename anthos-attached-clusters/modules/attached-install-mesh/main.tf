/**
 * Copyright 2018-2024 Google LLC
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
  tmp_credentials_path = "${path.module}/terraform-google-credentials.json"
  cache_path           = "${path.module}/.cache/${random_id.cache.hex}"
  gcloud_tar_path      = "${local.cache_path}/google-cloud-sdk.tar.gz"
  gcloud_bin_path      = "${local.cache_path}/google-cloud-sdk/bin"
  gcloud_bin_abs_path  = abspath(local.gcloud_bin_path)

  gcloud              = "${local.gcloud_bin_path}/gcloud"
  gcloud_download_url = var.gcloud_download_url != null ? var.gcloud_download_url : "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${var.gcloud_sdk_version}-${var.platform}-x86_64.tar.gz"
  jq_platform         = var.platform == "darwin" ? "osx-amd" : var.platform
  jq_download_url     = var.jq_download_url != null ? var.jq_download_url : "https://github.com/stedolan/jq/releases/download/jq-${var.jq_version}/jq-${local.jq_platform}64"
  asmcli_download_url = var.asmcli_download_url != null ? var.asmcli_download_url : "https://storage.googleapis.com/csm-artifacts/asm/asmcli_${var.asmcli_version}"

  asmcli_options = join("", [
    " --ca ${var.asmcli_ca}",
    var.asmcli_enable_all ? " --enable_all" : "",
    var.asmcli_enable_cluster_roles ? " --enable_cluster_roles" : "",
    var.asmcli_enable_cluster_labels ? " --enable_cluster_labels" : "",
    var.asmcli_enable_gcp_components ? " --enable_gcp_components" : "",
    var.asmcli_enable_gcp_apis ? " --enable_gcp_apis" : "",
    var.asmcli_enable_gcp_iam_roles ? " --enable_gcp_iam_roles" : "",
    var.asmcli_enable_meshconfig_init ? " --enable_meshconfig_init" : "",
    var.asmcli_enable_namespace_creation ? " --enable_namespace_creation" : "",
    var.asmcli_enable_registration ? " --enable_registration" : "",
    var.asmcli_verbose ? " --verbose" : "",
    var.asmcli_additional_arguments != null ? " ${var.asmcli_additional_arguments}" : ""
  ])

  cmd_entrypoint  = "${local.gcloud_bin_path}/asmcli"
  create_cmd_body = "install --kubeconfig ${var.kubeconfig} --context ${var.context} --fleet_id ${var.fleet_id} --platform multicloud --option attached-cluster${local.asmcli_options}"

  wait = length(null_resource.additional_components[*].triggers) + length(
    null_resource.gcloud_auth_service_account_key_file[*].triggers,
    ) + length(null_resource.gcloud_auth_google_credentials[*].triggers,
  ) + length(null_resource.run_command[*].triggers)

  prepare_cache_command                        = "mkdir -p ${local.cache_path}"
  download_gcloud_command                      = "curl -sL -o ${local.cache_path}/google-cloud-sdk.tar.gz ${local.gcloud_download_url}"
  download_jq_command                          = "curl -sL -o ${local.cache_path}/jq ${local.jq_download_url} && chmod +x ${local.cache_path}/jq"
  download_asmcli_command                      = "curl -sL -o ${local.cache_path}/asmcli ${local.asmcli_download_url} && chmod +x ${local.cache_path}/asmcli"
  decompress_command                           = "tar -xzf ${local.gcloud_tar_path} -C ${local.cache_path} && cp ${local.cache_path}/jq ${local.cache_path}/google-cloud-sdk/bin/ && cp ${local.cache_path}/asmcli ${local.cache_path}/google-cloud-sdk/bin/"
  additional_components_command                = "${path.module}/scripts/check_components.sh ${local.gcloud} kubectl"
  gcloud_auth_service_account_key_file_command = "${local.gcloud} auth activate-service-account --key-file ${var.service_account_key_file}"
  activate_service_account                     = var.activate_service_account ? "${local.gcloud} auth activate-service-account --key-file ${local.tmp_credentials_path}" : "true"
  gcloud_auth_google_credentials_command       = <<-EOT
    printf "%s" "$GOOGLE_CREDENTIALS" > ${local.tmp_credentials_path} && \
    ${local.activate_service_account}
  EOT

}

resource "random_id" "cache" {
  byte_length = 4
}

resource "null_resource" "prepare_cache" {
  triggers = {
    arguments             = md5(local.create_cmd_body)
    prepare_cache_command = local.prepare_cache_command
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.prepare_cache_command
  }
}

resource "null_resource" "download_gcloud" {
  triggers = {
    arguments               = md5(local.create_cmd_body)
    download_gcloud_command = local.download_gcloud_command
    version                 = var.gcloud_sdk_version
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.download_gcloud_command
  }

  depends_on = [null_resource.prepare_cache]
}

resource "null_resource" "download_jq" {
  triggers = {
    arguments           = md5(local.create_cmd_body)
    download_jq_command = local.download_jq_command
    version             = var.jq_version
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.download_jq_command
  }

  depends_on = [null_resource.prepare_cache]
}

resource "null_resource" "download_asmcli" {
  triggers = {
    arguments               = md5(local.create_cmd_body)
    download_asmcli_command = local.download_asmcli_command
    version                 = var.asmcli_version
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.download_asmcli_command
  }

  depends_on = [null_resource.prepare_cache]
}

resource "null_resource" "decompress" {
  triggers = {
    arguments               = md5(local.create_cmd_body)
    decompress_command      = local.decompress_command
    download_gcloud_command = local.download_gcloud_command
    download_jq_command     = local.download_jq_command
    download_asmcli_command = local.download_asmcli_command
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.decompress_command
  }

  depends_on = [null_resource.download_gcloud, null_resource.download_jq, null_resource.download_asmcli]
}

resource "null_resource" "additional_components" {
  depends_on = [null_resource.decompress]

  triggers = {
    arguments                     = md5(local.create_cmd_body)
    additional_components_command = local.additional_components_command
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.additional_components_command
  }
}

resource "null_resource" "gcloud_auth_service_account_key_file" {
  count      = length(var.service_account_key_file) > 0 ? 1 : 0
  depends_on = [null_resource.decompress]

  triggers = {
    arguments                                    = md5(local.create_cmd_body)
    gcloud_auth_service_account_key_file_command = local.gcloud_auth_service_account_key_file_command
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.gcloud_auth_service_account_key_file_command
  }
}

resource "null_resource" "gcloud_auth_google_credentials" {
  count      = var.use_tf_google_credentials_env_var ? 1 : 0
  depends_on = [null_resource.decompress]

  triggers = {
    arguments                              = md5(local.create_cmd_body)
    gcloud_auth_google_credentials_command = local.gcloud_auth_google_credentials_command
  }

  provisioner "local-exec" {
    when    = create
    command = self.triggers.gcloud_auth_google_credentials_command
  }
}

resource "null_resource" "run_command" {
  depends_on = [
    null_resource.decompress,
    null_resource.additional_components,
    null_resource.gcloud_auth_google_credentials,
    null_resource.gcloud_auth_service_account_key_file
  ]

  triggers = {
    arguments           = md5(local.create_cmd_body)
    cmd_entrypoint      = local.cmd_entrypoint
    create_cmd_body     = local.create_cmd_body
    gcloud_bin_abs_path = local.gcloud_bin_abs_path
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
    PATH=${self.triggers.gcloud_bin_abs_path}:$PATH
    ${self.triggers.cmd_entrypoint} ${self.triggers.create_cmd_body}
    EOT
    environment = {
      PROJECT_ID = ""
    }
  }

}

resource "null_resource" "gcloud_auth_google_credentials_destroy" {
  count = var.use_tf_google_credentials_env_var ? 1 : 0
  triggers = {
    gcloud_auth_google_credentials_command = local.gcloud_auth_google_credentials_command
  }
  provisioner "local-exec" {
    when    = destroy
    command = self.triggers.gcloud_auth_google_credentials_command
  }
}

resource "null_resource" "gcloud_auth_service_account_key_file_destroy" {
  count = length(var.service_account_key_file) > 0 ? 1 : 0
  triggers = {
    gcloud_auth_service_account_key_file_command = local.gcloud_auth_service_account_key_file_command
  }

  provisioner "local-exec" {
    when    = destroy
    command = self.triggers.gcloud_auth_service_account_key_file_command
  }
}

resource "null_resource" "additional_components_destroy" {
  triggers = {
    additional_components_command = local.additional_components_command
  }

  provisioner "local-exec" {
    when    = destroy
    command = self.triggers.additional_components_command
  }
}

resource "null_resource" "decompress_destroy" {
  triggers = {
    decompress_command = local.decompress_command
  }

  provisioner "local-exec" {
    when    = destroy
    command = self.triggers.decompress_command
  }
}
