## Configure the OpenStack Cloud Provider for Kubernetes

This guide explains how to configure the [**OpenStack Cloud Provider for Kubernetes**](https://github.com/kubernetes/cloud-provider-openstack) to use the [OpenStack LBaaS](https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html)
for exposing Kubernetes Services.

---
### Pre-requisites

_The guide assumes the following:_
1. You already have an environment with [OpenStack Ussuri](https://releases.openstack.org/ussuri/index.html) or similar deployed with [LBaaS v2](https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html) configured and
functional
     - _(either your own OpenStack deployment or one on Google Compute Engine deployment following [the guide from this repository](/anthos-bm-openstack-terraform/docs/install_openstack_on_gce.md))_
2. You have completed the [Install Anthos Bare Metal on OpenStack with Terraform](/anthos-bm-openstack-terraform/docs/quickstart.md) quick start guide

If you have completed the *Install Anthos Bare Metal on OpenStack with Terraform*
guide then you would have the following in your workstation:
- The `openrc.sh` file used by the OpenStack CLI client downloaded
- The public and private key files for the SSH key named `abmNodeKey` stored at `~/.ssh`
- The Terraform variables file `terraform.tfvars` created at `<PATH_TO_THIS_REPO>/anthos-samples/anthos-bm-openstack-terraform`
- The _auto-generated_ Terraform state file `terraform.tfstate` created at `<PATH_TO_THIS_REPO>/anthos-samples/anthos-bm-openstack-terraform`

> **Note:** The name of the SSH key can be different if you had set the
> environment variable `SSH_KEY_NAME` to something else in [step 2.2](/docs/quickstart.md#22-create-and-upload-ssh-keys-to-be-used-by-the-openstack-vms) of the quick start

---
