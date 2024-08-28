## Install Anthos On-Prem clusters using Terraform

This directory hosts samples and how-to's for installing Anthos On-Prem clusters
_(i.e. Anthos on bare metal and Anthos on VMware)_ using the
`google_gkeonprem-*` resources in the
[Google Cloud Terraform provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

For more information, see the reference documentation for each resource.

---

#### Anthos clusters on bare metal (ABM)

| Type             | Sample _(by loadbalancer type)_                  | Terraform resources |
| ---------------- | ----------------------------------------------   | ------------------- |
| **user** cluster | Bundled [MetalLB](./abm_user_cluster_metallb/)   | [google_gkeonprem_bare_metal_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_bare_metal_cluster) </br> [google_gkeonprem_bare_metal_node_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_bare_metal_node_pool) |
| **user** cluster | [ManualLB](./abm_user_cluster_manuallb/)         | [google_gkeonprem_bare_metal_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_bare_metal_cluster) </br> [google_gkeonprem_bare_metal_node_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_bare_metal_node_pool) |

---

#### Anthos clusters on VMware (AVMware)

| Type             | Sample _(by loadbalancer type)_                 | Terraform resources |
| ---------------- | ----------------------------------------------- | ------------------- |
| **user** cluster | Bundled [MetalLB](./avmw_user_cluster_metallb/) | [google_gkeonprem_vmware_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_vmware_cluster) </br> [google_gkeonprem_vmware_node_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gkeonprem_vmware_node_pool) |

---
