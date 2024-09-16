
## Apigee Hybrid on Anthos Baremetal on Google Compute Engine VMs with Terraform

This is a sample Apigee Hybrid installation on Anthos Cluster on bare metal
running on GCE Virtual Machines.
[Apigee hybrid](https://cloud.google.com/apigee/docs/hybrid/v1.7/what-is-hybrid)
is a platform for developing and managing API proxies that features a hybrid
deployment model. The hybrid model includes a management plane hosted by Apigee
in the Cloud and a runtime plane that you install and manage on one of the
[supported Kubernetes platforms](https://cloud.google.com/apigee/docs/hybrid/supported-platforms).
An [Apigee organization](https://cloud.google.com/apigee/docs/api-platform/fundamentals/organization-structure)
is the top-level container in Apigee. It contains all your API proxies and
related resources. This installation will create an evaluation Apigee
Organization with the same name as the ID of the Google Cloud Project you use.

### Pre-requisites

> **NOTE:** We have provided a [utility script](./resources/run_prerequisite.sh)
  that checks and configures some of the following project/organization level
  prerequisites. You may use it to validate some of the requirements that follow.
  Please ensure you have authenticated the `gcloud` CLI to use the GCP project
  you intend to use before running this script.

- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the following installed
  - [Git](https://www.atlassian.com/git/tutorials/install-git)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (>= v0.15.5, < v1.2)

- A [Google Cloud Project](https://console.cloud.google.com/cloud-resource-manager?_ga=2.187862184.1029435410.1614837439-1338907320.1614299892)
  _(in which the resources for the setup will be provisioned)_
  - **Network:** The project must have a network called `default` with all the
    default firewall policies configured on it. If, default network creation is
    enabled for the organization, the project will already have it. In case the
    *`Skip default network creation`* policy is enforced, you can create a new
    VPC `network` called default in **auto mode**.
    _[See image for example.](./docs/images/default_network.png)_

  - **Quota:** The project must have the required quota. his sample requires 4
    VMs of `n1-standard-8` machine type. Ensure that there is enough quota for
    CPU, Memory and IP Addresses for the GCP Region you intend to use.


- A [Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
  in the project that satisfies **one** of the following requirements and its
  **[key file downloaded](/anthos-bm-gcp-terraform/docs/create_sa_key.md)** to the workstation:
    - The Service Account has `Owner` and `Apigee Organization Administrator` permissions
    - The Service Account has both `Editor`, `Project IAM Admin` and `Apigee Organization Administrator` permissions

- The following list of **Organizational Policy Constraints** enabled on the Google Cloud Organization your GCP Project is in:

    |  Policy Name                                 | Constraint Name                                   | Effective Polciy |
    |  ------------------------------------------- | ------------------------------------------------- | ---------------- |
    | Disable service account creation             | constraints/iam.disableServiceAccountCreation	   | Not Enforced     |
    | Disable service account key creation         | constraints/iam.disableServiceAccountKeyCreation  | Not enforced     |
    | Restrict VM IP Forwarding                    | constraints/compute.vmCanIpForward.               | Allowed All      |
    | Define allowed external IPs for VM instances | constraints/compute.vmExternalIpAccess	           | Allowed All      |
    | Shielded VMs                                 | constraints/compute.requireShieldedVm	           | Not Enforced     |
    | Require OS Login                             | constraints/compute.requireOsLogin.               | Not Enforced     |
    | Skip default network creation                | constraints/compute.skipDefaultNetworkCreation	   | Not Enforced     |
---

### Anthos on bare metal with Apigee on GCE VMs

The infrastructure for the Anthos on bare metal cluster is created using the
[anthos-bm-gcp-terraform](/anthos-bm-gcp-terraform) sample. The sample here
refers to the [anthos-bm-gcp-terraform](/anthos-bm-gcp-terraform) script as a
terraform module and provisions the GCE based infrastructure first. Then, it
executes additional steps that are specific to the Apigee installtion.

Once you complete this [quickstart guide](docs/quickstart.md) you will have the
following infrastructure setup in Google Cloud using Compute Engine VMs with
Anthos on bare metal running and Apigee installed. The diagram assumes that
none of the default values for the [variables](variables.tf) were changed other
than the ones mentioned in this guide.

![Bare metal infrastructure on Google Cloud using Compute Engine VMs](docs/images/abm_gcp_infra.png)

---
## Getting started

- [Terraform Module Information _(includes variables definitions)_](docs/variables.md)
- [Quickstart guide](docs/quickstart.md):
  - The terraform script sets up the GCE VM environment. The output of the
    script prints out the commands to follow to install Anthos on bare metal
    in the provisioned GCE VM and to **configure Apigee** in the new Anthos on
    bare metal cluster.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| credentials\_file | Path to the Google Cloud Service Account key file.<br>    This is the key that will be used to authenticate the provider with the Cloud APIs | `string` | n/a | yes |
| gcp\_login\_accounts | GCP account email addresses that must be allowed to login to the cluster using Google Cloud Identity. | `list(string)` | `[]` | no |
| mode | Indication of the execution mode. By default the terraform execution will end<br>    after setting up the GCE VMs where the Anthos bare metal clusters can be deployed.<br><br>    **setup:** create and initialize the GCE VMs required to install Anthos bare metal.<br><br>    **install:** everything up to 'setup' mode plus automatically run Anthos bare metal installation steps as well.<br><br>    **manuallb:** similar to 'install' mode but Anthos on bare metal is installed with ManualLB mode. | `string` | `"setup"` | no |
| project\_id | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| region | Google Cloud Region in which the Compute Engine VMs should be provisioned | `string` | `"us-central1"` | no |
| username | The name of the user to be created on each Compute Engine VM to execute the init script | `string` | `"tfadmin"` | no |
| zone | Zone within the selected Google Cloud Region that is to be used | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| admin\_vm\_ssh | Run the following command to provision the anthos cluster. |
| controlplane\_ip | You may access the control plane nodes of the Anthos on bare metal cluster<br>    by accessing this IP address. You need to copy the kubeconfig file for the<br>    cluster from the admin workstation to access using the kubectl CLI. |
| ingress\_ip | You may access the application deployed in the Anthos on bare metal cluster<br>    by accessing this IP address |
| installation\_check | Run the following command to check the Anthos bare metal installation status. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
