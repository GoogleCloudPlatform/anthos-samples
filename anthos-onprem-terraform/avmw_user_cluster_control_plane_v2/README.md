## Create Anthos on VMware **user** clusters (ControlPlaneV2) with Terraform

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
`<REPO_ROOT_DIR>/anthos-onprem-terraform/avmw_user_cluster_control_plane_v2`.

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
