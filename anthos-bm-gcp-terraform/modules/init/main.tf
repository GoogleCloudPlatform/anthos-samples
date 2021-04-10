locals {
  ssh_pub_key_template_file = "${path.root}/resources/ssh-keys.tpl"
  ssh_pub_key_file          = format(var.pub_key_path_template, var.hostname)
  ssh_private_key_file      = format(var.priv_key_path_template, var.hostname)
  cluster_yaml_file_name    = trimprefix(basename(var.cluster_yaml_path), ".")
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "temp_ssh_pub_key_file" {
  filename        = local.ssh_pub_key_file
  file_permission = "0600"
  content = templatefile(
    local.ssh_pub_key_template_file,
    { ssh_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh) }
  )
}

resource "local_file" "temp_ssh_priv_key_file" {
  filename        = local.ssh_private_key_file
  file_permission = "0600"
  content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
}

module "gcloud_add_ssh_key_metadata" {
  source                   = "terraform-google-modules/gcloud/google"
  version                  = "2.0.3"
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
    user        = "root"
    host        = var.publicIp
    private_key = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  }

  provisioner "file" {
    source      = var.cluster_yaml_path
    destination = "/root/${local.cluster_yaml_file_name}"
  }

  provisioner "file" {
    source      = var.init_vars_file
    destination = "/root/init.vars"
  }

  provisioner "file" {
    source      = var.init_script
    destination = "/root/init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /root/init.vars",
      "chmod 0100 /root/init.sh",
      "chmod 0600 /root/${local.cluster_yaml_file_name}"
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
      root@${var.publicIp}              \
      'nohup /root/init.sh > /root/init.log 2>&1 &'
    EOT
  }
}
