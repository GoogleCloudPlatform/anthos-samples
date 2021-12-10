
## Anthos Baremetal on Google Compute Engine VMs with Terraform

This repository shows you how to use Terraform to try Anthos clusters on bare metal in High Availability (HA) mode using Virtual Machines (VMs) running on Compute Engine. For information about how to use the `gcloud` command-line tool to try this, see [Try Anthos clusters on bare metal on Compute Engine VMs](https://cloud.google.com/anthos/clusters/docs/bare-metal/1.6/try/gce-vms).

### Pre-requisites

- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the following installed
  - [Git](https://www.atlassian.com/git/tutorials/install-git)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (>= v0.15.5, < v1.1)

- A [Google Cloud Project](https://console.cloud.google.com/cloud-resource-manager?_ga=2.187862184.1029435410.1614837439-1338907320.1614299892) _(in which the resources for the setup will be provisioned)_

- A [Service Account](https://cloud.devsite.corp.google.com/iam/docs/creating-managing-service-accounts) in the project that satisfies **one** of the following requirements and its **[key file downloaded](https://cloud.devsite.corp.google.com/iam/docs/creating-managing-service-account-keys)** to the workstation:
  - The Service Account has `Owner` permissions
  - The Service Account has both `Editor` and `Project IAM Admin` permissions

---
### Bare metal infrastructure on Google Cloud using Compute Engine VMs

The [Quick starter](docs/quickstart.md) guide sets up the following infrastructure in Google Cloud using Compute Engine VMs. The diagram assumes that the none of the default values for the [variables](variables.tf) were changed other than the ones mentioned in the quick starter.

![Bare metal infrastructure on Google Cloud using Compute Engine VMs](resources/images/abm_gcp_infra.svg)

---
## Getting started

- [Quick starter guide](docs/quickstart.md)
- [Variables guide](docs/variables.md)

---
## Contributing

#### Pre-requisites
- The same [pre-requisites](#pre-requisites) to run this sample is required for testing as well

#### Pull requests
- For improvements to this sample submit your pull requests to the `main` branch

#### Testing
- Ensure that the improvements have _unit/integration tests_ where appropriate
- To run the existing tests you have to set two environment variables
```bash
export GOOGLE_CLOUD_PROJECT="<YOUR_GOOGLE_CLOUD_PROJECT>"
export GOOGLE_APPLICATION_CREDENTIALS="<PATH_TO_THE_SERVICE_ACCOUNT_KEY_FILE>"
```
- Move into the test directory and recursively execute the tests
```bash
cd anthos-bm-gcp-terraform/test
go test -v -timeout 30m ./...
```
