## Create Anthos on bare metal **user** clusters (ManualLB) with Terraform


---
### Prerequisite

#### Create admin cluster and VMs for user cluster

> **Note:** If you already have an admin cluster and the bare metal nodes for
> a new user cluster, then you can skip this step. But don't forget to update
> the sample with the values appropriate to your environment.

- First

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
