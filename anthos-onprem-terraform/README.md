## Install Anthos On-Prem clusters using Terraform

This directory hosts samples and how-to's for installing Anthos On-Prem clusters
_(i.e. Anthos on bare metal and Anthos on VMware)_ using the
`google_gkeonprem-*` resources in the
[Google Cloud Terraform provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

For more information, see the reference documentation for each resource:

* Anthos clusters on bare metal:

   * [google_gkeonprem_bare_metal_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_bare_metal_cluster)
   * [google_gkeonprem_bare_metal_node_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_bare_metal_node_pool)

* For Anthos clusters on VMware:

    * [google_gkeonprem_vmware_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_vmware_cluster)
    * [google_gkeonprem_vmware_node_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_vmware_node_pool)
