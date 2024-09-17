## Create Anthos on VMware **user** clusters (MetalLB) with Terraform

We show an example of how to create an Anthos on VMware
**user cluster** with **MetalLB** using the Google provider for Terraform.

The sample here assumes that the user has already created an admin cluster and
that it follows the prerequisites outlined in
[public documentation](https://cloud.google.com/anthos/clusters/docs/on-prem/latest/how-to/create-user-cluster-api#before_you_begin) to leverage the GKE on prem API for
the Cloud Console including registering the admin cluster and enabling admin
activity logs and system level log/mon on the admin cluster.

The minimum user cluster version for the public preview is Anthos 1.13.0.

### Create the user cluster with terraform

The steps that follow assumes that you already have this repo cloned locally and
have changed directory to where this samples is:
`<REPO_ROOT_DIR>/anthos-onprem-terraform/avmw_user_cluster_metallb`.

- Make a copy of the `terraform.tfvars.sample` file:

    ```sh
    cp terraform.tfvars.sample terraform.tfvars
    ```
    The sample terraform variables file has most of the default values filled in.

- Update missing variables in the `terraform.tfvars` file:
  - **`project_id`**: The GCP project of the admin cluster and where the user
    cluster will be created.
  - **`region`**: The Google Cloud region in which the Anthos On-Prem API
    runs.
  - **`admin_cluster_name`**: The name of the admin cluster that will manage the
    new user cluster.
  - **`on_prem_version`**: The Anthos clusters on VMware version for
    your user cluster.

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
---

### Upgrade the user cluster with terraform

Use the same terraform script to upgrade the user cluster, by simply changing
the version to the new version. Note that this script can be used for upgrades
only if you had created the user cluster using this script. When you run the
script with the updated version, the `terraform.tfstate` created during the
first run of the script is compared to recognize the change.

Before upgrading the user cluster, please make sure the admin cluster has been
enrolled in the Anthos On-Prem API. Steps for enrolling the admin cluster are
listed in [public documentation](https://cloud.google.com/anthos/clusters/docs/on-prem/latest/how-to/enroll-cluster#enroll_a_cluster).

An example using gcloud command to enroll the admin cluster is shown below:

```bash
gcloud beta container vmware admin-clusters enroll ADMIN_CLUSTER_NAME \
   --project=FLEET_HOST_PROJECT_ID \
   --admin-cluster-membership=projects/FLEET_HOST_PROJECT_ID/locations/global/memberships/ADMIN_CLUSTER_NAME \
   --location=REGION
```

This `gcloud_update_admin_cluster_platform_controller` module uses the `gcloud`
command prepare the admin cluster to enable the user cluster upgrade.

- [**`gcloud_update_admin_cluster_platform_controller`**](./main.tf#L53-L65):
   This module is used to ensure that the ** platform controller** of the admin cluster
   is on a compatible version. The platform controller contains one or more bundles of
   components that the admin cluster uses to manage user clusters. The bundles are
   version specific, that is, the platform controller must contain a bundle version that
   matches the _Anthos on VMware version of the user cluster_.  Thus, by having this
   module in the script we ensure that the platform controller in the admin cluster is
   always on the correct user cluster version.

Then, following the steps below to upgrade the user cluster via terraform.

- Update the version variable in the `terraform.tfvars` file:
  - **`on_prem_version`**: The Anthos clusters on VMware version for your user
    cluster.

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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_cluster\_name | The name of the admin cluster that manages the user cluster. The admin cluster<br>    name is the last segment of the fully-specified cluster name that uniquely<br>    identifies the cluster in Google Cloud:<br>    projects/FLEET\_HOST\_PROJECT\_ID/locations/global/memberships/ADMIN\_CLUSTER\_NAME | `string` | n/a | yes |
| admin\_user\_emails | Email addresses of GCP accounts that will be designated as administrator<br>    accounts of the cluster. | `list(string)` | n/a | yes |
| cluster\_name | The name of the user cluster to be created | `string` | `"vmware-metallb-user-cluster"` | no |
| control\_plane\_node\_cpus | The number of CPUs for each admin cluster node that serve as control planes<br>    for this VMware user cluster. | `number` | `4` | no |
| control\_plane\_node\_memory | The megabytes of memory for each admin cluster node that serves as a<br>    control plane for this VMware user cluster. | `number` | `8192` | no |
| control\_plane\_node\_replicas | The number of control plane nodes for this VMware user cluster. | `number` | `3` | no |
| control\_plane\_vip | The virtual IP address (VIP) that you have chosen to configure on the load<br>    balancer for the Kubernetes API server of the user cluster. | `string` | n/a | yes |
| ingress\_vip | The IP address that you have chosen to configure on the load balancer for<br>    the ingress proxy. | `string` | n/a | yes |
| lb\_address\_pools | The list of address pool configurations to be used by the MetalLB load balancer.<br>    Every address of each address pool must be a range either in CIDR or hyphenated-range<br>    format. To specify a single IP address in a pool (such as for the ingress VIP),<br>    use /32 in CIDR notation (ex. 192.0.2.1/32). | `list(object({ name = string, addresses = list(string) }))` | n/a | yes |
| on\_prem\_version | The Anthos clusters on the VMware version for your user cluster.<br>     Defaults to the admin cluster version. | `string` | n/a | yes |
| project\_id | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| region | The Google Cloud region in which the Anthos On-Prem API runs. Specify<br>    a supported region. | `string` | `"us-west1"` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
