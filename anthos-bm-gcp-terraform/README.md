
## Anthos Baremetal on Google Compute Engine VMs with Terraform

This repository shows you how to use Terraform to try Anthos clusters on bare metal in High Availability (HA) mode using Virtual Machines (VMs) running on Compute Engine. For information about how to use the `gcloud` command-line tool to try this, see [Try Anthos clusters on bare metal on Compute Engine VMs](https://cloud.google.com/anthos/clusters/docs/bare-metal/1.6/try/gce-vms).

### Pre-requisites

- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the following installed
  - [Git](https://www.atlassian.com/git/tutorials/install-git)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (~v0.14.10)

- A [GCP Project](https://console.cloud.google.com/cloud-resource-manager?_ga=2.187862184.1029435410.1614837439-1338907320.1614299892) _(in which the resources for the setup will be provisioned)_ with the following setup
  - The project added to a [monitoring workspace](https://console.cloud.google.com/monitoring?_ga=2.256070603.1395081395.1617860495-190605143.1617846491). _You can create a new workspace for the project or associate it to an existing one._
  - A [Service Account](https://cloud.devsite.corp.google.com/iam/docs/creating-managing-service-accounts) in the project with either `Project Editor` or `Project Owner` permissions and its **[key file downloaded to the workstation](https://cloud.devsite.corp.google.com/iam/docs/creating-managing-service-account-keys)**
---
### Bare metal infrastructure on Google Cloud using Compute Engine VMs

The [Quick starter](docs/quickstarter.md) guide sets up the following infrastructure in Google Cloud using Compute Engine VMs. The diagram assumes that the none of the default values for the [variables](variables.tf) were changed other than the ones mentioned in the quick starter.

![Bare metal infrastructure on Google Cloud using Compute Engine VMs](resources/images/abm_gcp_infra.svg)

---
## Getting started

 ## Troubleshooting

## Development

## Contributing
