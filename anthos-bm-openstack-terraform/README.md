## Anthos on bare metal on OpenStack with Terraform

This sample shows you how to use Terraform to try Anthos clusters on bare
metal in High Availability (HA) mode using Virtual Machines (VMs) running on
[OpenStack](https://www.openstack.org/). The guide also shows how to configure
the [OpenStack Cloud Provider for Kubernetes](https://github.com/kubernetes/cloud-provider-openstack)
on the Anthos on bare metal cluster. This guide has been tested on OpenStack
[Ussuri](https://releases.openstack.org/ussuri/index.html) and assumes that you
already have a similar OpenStack environment running.

---
### Infrastructure on OpenStack

This guide sets up the following infrastructure on your OpenStack environment.
The diagram below assumes that none of the default values for the
[variables](variables.tf) were changed other than the ones mentioned in the
guide.
<p align="center">
  <img src="docs/images/openstack-setup.png" width="700">
</p>

- Private Network for the VMs
- Private SSH key that is uploaded to all VMs
- External Load Balancer using Octavia LBaaS
- 3 Nova VMs ***(1 Admin workstation, 1 Control plane and 1 Worker node)***
- Router to provide external connectivity and for floating IP addresses
- Security Group that allows all ICMP and incoming TCP on port 22 and 443 from 0.0.0.0/0
- A [***cloud-config***](resources/cloud-config.yaml) that sets up SSH access to all VMs from all VMs under the user **`abm`**

---

### Pre-requisites
- A bare metal environment running [OpenStack Ussuri](https://releases.openstack.org/ussuri/index.html)
  or similar with [LBaaS v2](https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html)
  configured and functional
  > If you don't have an OpenStack environment and still want to try this sample
    then first follow [this guide](/anthos-bm-openstack-terraform/docs/install_openstack_on_gce.md)
    to get an OpenStack _(Ussuri)_ environment running on a [Google Compute Engine VM with _nested KVM_](https://cloud.google.com/compute/docs/instances/nested-virtualization/overview).

- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the
  following installed
  - [Git](https://www.atlassian.com/git/tutorials/install-git)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [OpenStack CLI Client](https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html)
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) _(>=v0.15.5)_

- A [Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) _(which will host the Anthos Hub)_
- **Time**: this entire guide can take upto **45 minutes** to complete if you already have an OpenStack environment running

---
## Getting started

- [Deploy OpenStack Ussuri on GCE VM](/anthos-bm-openstack-terraform/docs/install_openstack_on_gce.md)
  - _(required only if you already don't have an **OpenStack Ussuri** or similar with **LBaaS v2** enabled)_
- [Provision the OpenStack VMs and network setup using Terraform](docs/configure_openstack.md)
- [Install Anthos bare metal on OpenStack](docs/install_abm.md)
- [Configure the OpenStack Cloud Provider on the Anthos on bare metal cluster](docs/openstack_cloud_provider.md)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| external\_network\_id | The id of the external network that is used for floating IP addresses | `string` | n/a | yes |
| image | The source image to use when provisioning the OpenStack VMs.<br>    Use 'openstack image list' to find a list of all available images | `string` | `"ubuntu-2004"` | no |
| instance\_count | Number of instances to provision per layer (Control plane and Worker nodes) of the cluster | `map(any)` | <pre>{<br>  "controlplane": 1,<br>  "worker": 1<br>}</pre> | no |
| lb\_method | The algorithm to use for load balancing requests. Valid values are<br>    ROUND\_ROBIN, LEAST\_CONNECTIONS, SOURCE\_IP, or SOURCE\_IP\_PORT | `string` | `"ROUND_ROBIN"` | no |
| machine\_type | The machine type to use when provisioning the OpenStack VMs.<br>    Use 'openstack flavor list' to find a list of all available flavors | `string` | `"m1.jumbo"` | no |
| network\_mtu | The Maximum Transport Unit for packets over the OpenStack network | `number` | `1400` | no |
| os\_auth\_url | The OpenStack authentication URL to be used by the provider | `string` | n/a | yes |
| os\_endpoint\_type | The type of the OpenStack endpoint to use; whether its public or internal | `string` | `"internalURL"` | no |
| os\_password | The password to be used to authenticate the OpenStack provider client | `string` | n/a | yes |
| os\_region | The OpenStack region in which the VMs are to be provisioned | `string` | `"RegionOne"` | no |
| os\_tenant\_name | The OpenStack tenant information for the current setup | `string` | `"admin"` | no |
| os\_user\_name | The username to be used to authenticate the OpenStack provider client | `string` | n/a | yes |
| ssh\_key\_name | The name of the SSH key pair to associate with the provisioned OpenStack VMs.<br>    Use 'openstack key list' to find a list of all available keys | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| admin\_ws\_public\_ip | Public IP address of the admin workstation VM in the Openstack deployment |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
