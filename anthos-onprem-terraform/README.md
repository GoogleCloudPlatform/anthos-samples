## Install Anthos onPrem clusters using Terraform

This directory hosts samples and how-to's for installing Anthos onPrem clusters
_(i.e. Anthos on bare metal and Anthos on VMware)_ using the
`google_gkeonprem-*` resources of the canonical
[Google Cloud Terraform provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).


Most samples here, first **emulates** a bare metal infrastucture using
Compute Engine (GCE) VMs. It is on this imaginary bare metal environment the
clusters are installed. Thus, as a prestep to all the guides here, you will see
a step for provisioning the bare metal insfrastructure. If you have your own
bare metal infrastructure, you can skip that section and adjust the sample to
suit your environment.

<!--
# TODO: Add links to the Terraform provider once it has been published
-->
---

### Anthos clusters on bare metal (ABM)
- Create **admin** clusters with Terraform `(coming soon)`
   - See [guide](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/creating-clusters/create-admin-cluster-api) for creating an admin cluster using other clients
- Create **user** clusters with Terraform
  - [MetalLB](./abm_user_cluster_metallb/)
  - [ManualLB](./abm_user_cluster_manuallb/)
- Create **standalone** clusters with Terraform `(coming soon)`
---

### Anthos clusters on VMware (AVMware)
- Create **admin** clusters with Terraform `(coming soon)`
- Create **user** clusters with Terraform
  - [MetalLB](./avmw_user_cluster_metallb/)
  - ManualLB `(coming soon)`
- Create **standalone** clusters with Terraform `(coming soon)`

---
