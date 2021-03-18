output admin_vm_ssh {
  description = "Run the following command to provision the anthos cluster."
  value = join("\n", [
    "################################################################################",
    "##                       AnthosBM on GCE with Terraform                       ##",
    "##                        (Run the following commands)                        ##",
    "##     (Note that the 3rd line onwards runs inside the SSH'ed admin host)     ##",
    "################################################################################",
    "",
    "> gcloud compute --project ${var.project_id} scp ./scripts/anthos_gce_cluster.yaml root@${local.admin_vm_hostnames[0]}:~ --zone=${var.zone}",
    "> gcloud compute --project ${var.project_id} ssh root@${local.admin_vm_hostnames[0]} --zone=${var.zone}",
    "",
    "> # Use must be SSH'ed into the admin host ${local.admin_vm_hostnames[0]} as root user now",
    "> # ----------------------------------------------------------------------------",
    "> export PROJECT_ID=$(gcloud config get-value project)",
    "> export CLUSTER_ID=anthos-gce-cluster",
    "> bmctl create config -c $CLUSTER_ID",
    "> sed -i 's/$CLUSTER_ID/'$CLUSTER_ID'/g' anthos_gce_cluster.yaml",
    "> sed 's/$PROJECT_ID/'$PROJECT_ID'/g' anthos_gce_cluster.yaml > bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID.yaml",
    "> bmctl create cluster -c $CLUSTER_ID",
    "",
    "################################################################################",
  ])
}
