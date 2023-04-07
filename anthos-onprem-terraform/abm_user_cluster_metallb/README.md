## Create Anthos on bare metal **user** clusters (MetalLB) with Terraform

The steps here acheive the same result as what is explained in the
[Create an Anthos on bare metal user cluster on Compute Engine VMs using Anthos On-Prem API clients](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/try/admin-user-gce-vms)
public documentation. We show an example of how to create an Anthos on bare
metal **user cluster** with **MetalLB** using the Google provider for Terraform.

The sample here has a prerequisite step of creating an **admin cluster** using
the [script available in this repository](/anthos-bm-gcp-bash/install_admin_cluster.sh).
Thus, the default variables (especially IP addresses) configures in