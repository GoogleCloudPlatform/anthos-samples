## Create Anthos on bare metal **user** clusters (MetalLB) with Terraform

The steps here acheive the same result as what is explained in the
[Create an Anthos on bare metal user cluster on Compute Engine VMs using Anthos On-Prem API clients](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/try/admin-user-gce-vms)
public documentation. We show an example of how to create an Anthos on bare
metal **user cluster** with **MetalLB** using the Google provider for Terraform.

The sample here has a prerequisite step of creating an **admin cluster** using
the [script available in this repository](/anthos-bm-gcp-bash/install_admin_cluster.sh).
Thus, the default variables _(especially IP addresses)_ used in this sample are
based on the assumption that the admin cluster and the GCE VM based bare metal
infrstructure for the user cluster was created using that script. If you
already have an **admin cluster and bare metal nodes for the user cluster**, you
may skip running this script. However, you will have to update the sample to use
values appropriate to your environment.

---
### Prerequisite

#### Create admin cluster and VMs for user cluster

> **Note:** If you already have an admin cluster and the bare metal nodes for
> a new user cluster, then you can skip this step. But don't forget to update
> the sample with the values appropriate to your environment.

- First you will have to create an admin cluster that will manage your user
  cluster. At the time of writing this guide, admin cluster creation
  **using Terraform** is not supported.

- Follow the [instructions here](/anthos-bm-gcp-bash/docs/admin.md) to create an
  admin cluster and to provision the GCE VMs for the user cluster using the
  [install_admin_cluster.sh](/anthos-bm-gcp-bash/install_admin_cluster.sh)
  script.

- Upon completion, you will see the node information for the GCE VMs printed on
  screen.

    ```sh
    |---------------------------------------------------------------------------------------------------------|
    | VM Name               | L2 Network IP (VxLAN) | INFO                                                    |
    |---------------------------------------------------------------------------------------------------------|
    | abm-admin-cluster-cp1 | 10.200.0.3            | Has control plane of admin cluster running inside       |
    | abm-user-cluster-cp1  | 10.200.0.4            | 🌟 Ready for use as control plane for the user cluster  |
    | abm-user-cluster-w1   | 10.200.0.5            | 🌟 Ready for use as worker for the user cluster         |
    | abm-user-cluster-w2   | 10.200.0.6            | 🌟 Ready for use as worker for the user cluster         |
    |---------------------------------------------------------------------------------------------------------|
    ```

#### Create the user cluster with terraform

The steps that follow assumes that you already have this repo cloned locally and
have changed directory to where this samples is:
`<REPO_ROOT_DIR>/anthos-onprem-terraform/abm_user_cluster_metallb`.

- Make a copy of the `terraform.tfvars.sample` file:

    ```sh
    cp terraform.tfvars.sample terraform.tfvars
    ```
    The sample terraform vaiables file has most of the default values filled in
    based on the output of the [install_admin_cluster.sh](/anthos-bm-gcp-bash/install_admin_cluster.sh)
    script from the previous section.

- Update missing variables in the `terraform.tfvars` file:
  - **`project_id`**: The GCP project of the admin cluster and where the user
    cluster will be created.
  - **`region`**: The Google Cloud region in which the Anthos On-Prem API
    runs.
  - **`admin_cluster_name`**: The name of the admin cluster that will manage the
    new user cluster. If you used the [install_admin_cluster.sh](/anthos-bm-gcp-bash/install_admin_cluster.sh)
    script and used the default name, then this must be `abm-admin-cluster`.
  - **`bare_metal_version`**: The Anthos clusters on bare metal version for
    your user cluster. This must be same as the admin cluster version or one
    minor version less, at most. It cannot be higher in any case - minor or
    patch.

  - **`admin_user_emails`**: List of GCP accounts that must be given
    administrator rights on the user cluster.

- Execute terraform:

    ```sh
    terraform init
    ```
    ```sh
    terraform plan
    ```
    ```sh
    terraform apply
    ```

    Once completed you will see an output as follows:
    ```sh
    ...

    ```

    You can view your user cluster in the
    [Anthos clusters page](https://console.cloud.google.com/anthos/clusters).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_cluster\_name | The name of the admin cluster that manages the user cluster. The admin cluster<br>    name is the last segment of the fully-specified cluster name that uniquely<br>    identifies the cluster in Google Cloud:<br>    projects/FLEET\_HOST\_PROJECT\_ID/locations/global/memberships/ADMIN\_CLUSTER\_NAME | `string` | n/a | yes |
| admin\_user\_emails | Email addresses of GCP accounts that will be designated as administrator<br>    accounts of the cluster. | `list(string)` | n/a | yes |
| bare\_metal\_version | The Anthos clusters on bare metal version for your user cluster. The terraform<br>    provider based cluster creation is only supported for Anthos bare metal<br>    versions 1.13.1 and later | `string` | n/a | yes |
| cluster\_name | The name of the user cluster to be created | `string` | `"bm-metallb-user-cluster"` | no |
| control\_plane\_ips | The IPv4 address of the control plane nodes. Control plane nodes run the system<br>    workload. Typically, you have a single machine if using a minimum deployment,<br>    or three machines if using a high availability (HA) deployment. Specify an odd<br>    number of nodes to have a majority quorum for HA. You can change these<br>    addresses whenever you update or upgrade a cluster | `list(string)` | n/a | yes |
| control\_plane\_vip | The virtual IP address (VIP) that you have chosen to configure on the load<br>    balancer for the Kubernetes API server of the user cluster. | `string` | n/a | yes |
| ingress\_vip | The IP address that you have chosen to configure on the load balancer for<br>    the ingress proxy. | `string` | n/a | yes |
| lb\_address\_pools | The list of address pool configurations to be used by the MetalLB load balancer.<br>    Every address of each address pool must be a range either in CIDR or hyphenated-range<br>    format. To specify a single IP address in a pool (such as for the ingress VIP),<br>    use /32 in CIDR notation (ex. 192.0.2.1/32). | `list(object({ name = string, addresses = list(string) }))` | n/a | yes |
| project\_id | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| region | The Google Cloud region in which the Anthos On-Prem API runs. Specify<br>    a supported region:<br>    https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/reference/supported-regions-on-prem-api | `string` | `"us-west1"` | no |
| worker\_node\_ips | The IPv4 address of a worker node. | `list(string)` | n/a | yes |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
