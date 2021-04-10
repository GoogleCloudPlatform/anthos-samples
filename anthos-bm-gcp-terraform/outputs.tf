output admin_vm_ssh {
  description = "Run the following command to provision the anthos cluster."
  value = join("\n", [
    "################################################################################",
    "##              AnthosBM on Google Compute Engine VM with Terraform           ##",
    "##                        (Run the following commands)                        ##",
    "##   (Note that the 1st command should have you SSH'ed into the admin host)   ##",
    "################################################################################",
    "",
    "> ssh  -o 'StrictHostKeyChecking no' \\",
    "       -o 'UserKnownHostsFile /dev/null' \\",
    "       -o 'IdentitiesOnly yes' \\",
    "       -F /dev/null \\",
    "       -i ${path.root}/resources/.temp/${local.admin_vm_hostnames[0]}/ssh-key.priv \\",
    "       ${var.username}@${local.publicIps[local.admin_vm_hostnames[0]]}",
    "",
    "> # You must be SSH'ed into the admin host ${local.admin_vm_hostnames[0]} as ${var.username} user now",
    "> # ----------------------------------------------------------------------------",
    "> sudo bmctl create config -c ${var.abm_cluster_id} && \\",
    "  sudo cp ~/${var.abm_cluster_id}.yaml bmctl-workspace/${var.abm_cluster_id} && \\",
    "  sudo bmctl create cluster -c ${var.abm_cluster_id}",
    "",
    "################################################################################",
  ])
}
