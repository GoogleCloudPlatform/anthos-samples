output admin_vm_ssh {
  description = "Run the following command to provision the anthos cluster."
  value = join("\n", [
    "################################################################################",
    "##              AnthosBM on Google Compute Engine VM with Terraform           ##",
    "##                        (Run the following commands)                        ##",
    "##     (Note that the 1st line should have you SSH'ed into the admin host)    ##",
    "################################################################################",
    "",
    "> gcloud compute ssh root@${local.admin_vm_hostnames[0]} --project=${var.project_id} --zone=${var.zone}",
    "",
    "> # You must be SSH'ed into the admin host ${local.admin_vm_hostnames[0]} as root user now",
    "> # ----------------------------------------------------------------------------",
    "> bmctl create config -c ${var.abm_cluster_id} && \\",
    "  cp ~/${var.abm_cluster_id}.yaml bmctl-workspace/${var.abm_cluster_id} && \\",
    "  bmctl create cluster -c ${var.abm_cluster_id}",
    "",
    "################################################################################",
  ])
}
