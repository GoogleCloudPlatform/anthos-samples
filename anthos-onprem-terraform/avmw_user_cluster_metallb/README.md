## Create Anthos on VMware **user** clusters (MetalLB) with Terraform

We show an example of how to create an Anthos on VMware
**user cluster** with **MetalLB** using the Google provider for Terraform.

The sample here assumes that the user has already created an admin cluster and
that it follows the prerequisites outlined in
[public documentation](https://cloud.google.com/anthos/clusters/docs/on-prem/latest/how-to/create-user-cluster-api#before_you_begin) to leverage the GKE on prem API for
the Cloud Console including registering the admin cluster and enabling admin
activity logs and system level log/mon on the admin cluster.

The minimum user cluster version for the private preview is Anthos 1.13.0.

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

Before upgrading the user cluster, please make sure the admin cluster platform
controller has been upgraded to the target version. The steps to upgrade the
admin cluster platform controller is listed in the
[public documentation](https://cloud.google.com/anthos/clusters/docs/on-prem/latest/how-to/upgrade-on-prem-api#available_versions_for_upgrades).

An example is shown below:

```bash
gcloud beta container vmware admin-clusters update <ADMIN_CLUSTER_ID> \
  --required-platform-version=<TARGET_VERSION> \
  --location <REGION> \
  --project <FLEET_HOST_PROJECT_ID>
```

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
