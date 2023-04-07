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
  - **`admin_cluster_name`**: The name of the admin cluster that will manage the
    new user cluster. If you used the [install_admin_cluster.sh](/anthos-bm-gcp-bash/install_admin_cluster.sh)
    script and used the default name, then this must be `abm-admin-cluster`.
  - **`admin_user_emails`**: List of GCP accounts that must be given
    administrator rights on the user cluster. This field is commented out in the
    sample variables files. If you leave it commented out, then the create of
    the cluster will be made adminsitrator by default.

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