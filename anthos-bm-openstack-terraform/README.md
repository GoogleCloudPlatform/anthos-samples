## Anthos Baremetal on OpenStack with Terraform

This repository shows you how to use Terraform to try Anthos clusters on bare
metal in High Availability (HA) mode using Virtual Machines (VMs) running on
[OpenStack](https://www.openstack.org/). The guide has been tested on OpenStack
[Ussuri](https://releases.openstack.org/ussuri/index.html) and assumes that you
already have a similar OpenStack environment running.

### Pre-requisites
- A baremetal environment running [OpenStack Ussuri](https://releases.openstack.org/ussuri/index.html)
  or similar with [LBaaS v2](https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html)
  configured and functional
- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the
  following installed
  - [Git](https://www.atlassian.com/git/tutorials/install-git)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (~v0.14.10)

- A [Google Cloud Project](https://console.cloud.google.com/cloud-resource-manager?_ga=2.187862184.1029435410.1614837439-1338907320.1614299892) _(in which the resources for the setup will be provisioned)_

- A [Service Account](https://cloud.devsite.corp.google.com/iam/docs/creating-managing-service-accounts)
  in the project that satisfies **one** of the following requirements and its **[key file downloaded](https://cloud.devsite.corp.google.com/iam/docs/creating-managing-service-account-keys)** to
  the workstation:
  - The Service Account has `Owner` permissions
  - The Service Account has both `Editor` and `Project IAM Admin` permissions


---
### Anthos BareMetal infrastructure on OpenStack

The [Quick starter](docs/quickstart.md) guide sets up the following infrastructure on your OpenStack environment. The diagram assumes that none of the default values for the [variables](variables.tf) were changed other than the ones mentioned in the quick starter.
- External Load Balancer using Octavia LBaaS
- Private Network for the VMs
- A router to provide external connectivity and for floating IP addresses
- 3 Nova VMs: 1 Admin workstation, 1 Control plane and 1 worker node
- Security Group that allows all ICNM and incoming TCP on port 22 and 443 from 0.0.0.0/0
- Private SSH key that is uploaded to all VMs
- A cloud-config that sets up SSH access to all VMs from all VMs under
  the user `abm`

#### \<IMAGE HERE\>

---
