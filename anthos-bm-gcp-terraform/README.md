> #### This is a terraform script to provision the GCE infrastructure in which Anthos clusters on bare metal (ABM) will be installed. The cluster installation is done using `bash` scripts. This does NOT use the `google_gkeonprem_*` terraform resources of the `google` provider to create the ABM cluster. If you are looking for a sample that is fully based off of the terraform provider, see the [anthos-onprem-terraform](/anthos-onprem-terraform/) directory.
---

## Anthos Baremetal on Google Compute Engine VMs with Terraform

> Read the dosclaimer on top of this README before you continue.

This repository shows you how to use Terraform to try Anthos clusters on bare
metal in High Availability (HA) mode using Virtual Machines (VMs) running on
Compute Engine. For information about how to use the `gcloud` command-line tool
to try this, see [Try Anthos clusters on bare metal on Compute Engine VMs](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/try/gce-vms).

### Pre-requisites

- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the following installed
  - [Git](https://www.atlassian.com/git/tutorials/install-git)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (>= v0.15.5, < v1.4)

- A [Google Cloud Project](https://console.cloud.google.com/cloud-resource-manager?_ga=2.187862184.1029435410.1614837439-1338907320.1614299892) _(in which the resources for the setup will be provisioned)_

- A [Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
  in the project that satisfies **one** of the following requirements and its
  **[key file downloaded](docs/create_sa_key.md)** to the workstation:
  - The Service Account has `Owner` permissions
  - The Service Account has both `Editor` and `Project IAM Admin` permissions

---
### Bare metal infrastructure on Google Cloud using Compute Engine VMs

The [Quick starter](docs/quickstart.md) guide sets up the following
infrastructure in Google Cloud using Compute Engine VMs. The diagram assumes
that the none of the default values for the [variables](variables.tf) were
changed other than the ones mentioned in the quick starter.

![Bare metal infrastructure on Google Cloud using Compute Engine VMs](docs/images/abm_gcp_infra.svg)

---
## Getting started

- [Terraform Module Information _(includes variables definitions)_](docs/variables.md)

- [Quick start guide](docs/quickstart.md):
    - The terraform script sets up the GCE VM environment. The output of the
      script prints out the commands to follow to install
      **Anthos on bare metal** in the provisioned GCE VMs.

- [All in one install](docs/one_click_install.md):
    - The terraform script sets up the GCE VM environment and also triggers the
      **Anthos on bare metal** installation on the provisioned GCE VMs. The
      output of the script prints out the commands to SSH into the
      *admin workstation VM* and monitor the Anthos on bare metal installation
      process.

- [Manual LB install](docs/manuallb_install.md):
    - The terraform script sets up the GCE environment and triggers the
      **Anthos on bare metal** installation similar to the
      [all-in-one install](docs/one_click_install.md). However, in this mode
      **Anthos on bare metal** is installed with a
      [`Manual Loadbalancer`](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/manual-lb) instead of the default
      [`Bundled LB`](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/bundled-lb).
      We use
      [Google Cloud Loadbalancer](https://cloud.google.com/load-balancing/docs/load-balancing-overview)
      as the manual loadbalancer for the Anthos on bare metal cluster. The
      output of the script prints out the same instructions as the all-in-one
      install; additionally it also prints out the **Public IP** addresses of
      the loadbalancers.

- [NFS Shared Storage](docs/nfs.md):
    - An optional NFS server is provisioned in conjunction with any of the
      install methods above to provide shared storage to the
      **Anthos on bare metal** cluster.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| abm\_cluster\_id | Unique id to represent the Anthos Cluster to be created | `string` | `"cluster1"` | no |
| abm\_version | Version of Anthos Bare Metal | `string` | `"1.14.1"` | no |
| anthos\_service\_account\_name | Name given to the Service account that will be used by the Anthos cluster components | `string` | `"baremetal-gcr"` | no |
| as\_sub\_module | This script is being run as a sub module; thus output extra variables | `bool` | `false` | no |
| boot\_disk\_size | Size of the primary boot disk to be attached to the Compute Engine VMs in GBs | `number` | `200` | no |
| boot\_disk\_type | Type of the boot disk to be attached to the Compute Engine VMs | `string` | `"pd-ssd"` | no |
| credentials\_file | Path to the Google Cloud Service Account key file.<br>    This is the key that will be used to authenticate the provider with the Cloud APIs | `string` | n/a | yes |
| enable\_nested\_virtualization | Enable nested virtualization on the Compute Engine VMs are to be scheduled | `string` | `"true"` | no |
| gcp\_login\_accounts | GCP account email addresses that must be allowed to login to the cluster using Google Cloud Identity. | `list(string)` | `[]` | no |
| gpu | GPU information to be attached to the provisioned GCE instances.<br>    See https://cloud.google.com/compute/docs/gpus for supported types | `object({ type = string, count = number })` | <pre>{<br>  "count": 0,<br>  "type": ""<br>}</pre> | no |
| image | The source image to use when provisioning the Compute Engine VMs.<br>    Use 'gcloud compute images list' to find a list of all available images | `string` | `"ubuntu-2204-jammy-v20250712"` | no |
| image\_family | Source image to use when provisioning the Compute Engine VMs.<br>    The source image should be one that is in the selected image\_project | `string` | `"ubuntu-2204-lts"` | no |
| image\_project | Project name of the source image to use when provisioning the Compute Engine VMs | `string` | `"ubuntu-os-cloud"` | no |
| instance\_count | Number of instances to provision per layer (Control plane and Worker nodes) of the cluster | `map(any)` | <pre>{<br>  "controlplane": 3,<br>  "worker": 2<br>}</pre> | no |
| machine\_type | Google Cloud machine type to use when provisioning the Compute Engine VMs | `string` | `"n1-standard-8"` | no |
| min\_cpu\_platform | Minimum CPU architecture upon which the Compute Engine VMs are to be scheduled | `string` | `"Intel Haswell"` | no |
| mode | Indication of the execution mode. By default the terraform execution will end<br>    after setting up the GCE VMs where the Anthos bare metal clusters can be deployed.<br><br>    **setup:** create and initialize the GCE VMs required to install Anthos bare metal.<br><br>    **install:** everything up to 'setup' mode plus automatically run Anthos bare metal installation steps as well.<br><br>    **manuallb:** similar to 'install' mode but Anthos on bare metal is installed with ManualLB mode. | `string` | `"setup"` | no |
| network | VPC network to which the provisioned Compute Engine VMs is to be connected to | `string` | `"default"` | no |
| nfs\_server | Provision a Google Filestore instance for NFS shared storage | `bool` | `false` | no |
| primary\_apis | List of primary Google Cloud APIs to be enabled for this deployment | `list(string)` | <pre>[<br>  "cloudresourcemanager.googleapis.com"<br>]</pre> | no |
| project\_id | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| region | Google Cloud Region in which the Compute Engine VMs should be provisioned | `string` | `"us-central1"` | no |
| resources\_path | Path to the resources folder with the template files | `string` | n/a | yes |
| secondary\_apis | List of secondary Google Cloud APIs to be enabled for this deployment | `list(string)` | <pre>[<br>  "anthos.googleapis.com",<br>  "anthosgke.googleapis.com",<br>  "container.googleapis.com",<br>  "gkeconnect.googleapis.com",<br>  "gkehub.googleapis.com",<br>  "serviceusage.googleapis.com",<br>  "stackdriver.googleapis.com",<br>  "monitoring.googleapis.com",<br>  "logging.googleapis.com",<br>  "iam.googleapis.com",<br>  "compute.googleapis.com",<br>  "anthosaudit.googleapis.com",<br>  "opsconfigmonitoring.googleapis.com",<br>  "file.googleapis.com",<br>  "connectgateway.googleapis.com"<br>]</pre> | no |
| tags | List of tags to be associated to the provisioned Compute Engine VMs | `list(string)` | <pre>[<br>  "http-server",<br>  "https-server"<br>]</pre> | no |
| username | The name of the user to be created on each Compute Engine VM to execute the init script | `string` | `"tfadmin"` | no |
| zone | Zone within the selected Google Cloud Region that is to be used | `string` | `"us-central1-b"` | no |

## Outputs

| Name | Description |
|------|-------------|
| abm\_version | Version of Anthos Bare Metal |
| admin\_vm\_ssh | Run the following command to provision the anthos cluster. |
| admin\_workstation\_ip | This is the IP address of your admin workstation. You may access the Anthos<br>    on bare metal cluster by accessing this IP address. |
| admin\_workstation\_ssh\_key | This is the local file path for the SSH key of the admin workstation. You<br>    may use this to SSH into the admin workstation. |
| controlplane\_ip | You may access the control plane nodes of the Anthos on bare metal cluster<br>    by accessing this IP address. You need to copy the kubeconfig file for the<br>    cluster from the admin workstation to access using the kubectl CLI. |
| ingress\_ip | You may access the application deployed in the Anthos on bare metal cluster<br>    by accessing this IP address |
| installation\_check | Run the following command to check the Anthos bare metal installation status. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

---
## Contributing

#### Pre-requisites
- The same [pre-requisites](#pre-requisites) to run this sample is required for
  testing as well

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
