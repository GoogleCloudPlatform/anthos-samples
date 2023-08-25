## Create Anthos on bare metal **user** clusters (ManualLB) with Terraform

This sample is an example of how to create an Anthos on bare metal
**user cluster** in **ManualLB** mode using the
**`google_gkeonprem_bare_metal_*`** resources of the official Google terraform
provider. This is an alternate approach _(i.e. Terraform client)_ to what is
already explained in the
[Create a user cluster using Anthos On-Prem API clients](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/creating-clusters/create-user-cluster-api#manual)
public documentation.

The sample here assumes that you already have an **admin cluster** that will be
managing the new cluster. It also assumes that you have your own bare metal
infrastructure along with the _Manual load balancer_ setup to provision the new
cluster using this example.

We don't provide a complete installation guide for this sample, since the Manual
load balancer setup is a pre-requisite and is dependant on the network setup of
your bare metal infrastructure. Thus, we list out general guidelines for how
to use this sample.

> **Note:** Googlers can use [go/abm-tf-manuallb-guide](http://go/abm-tf-manuallb-guide)
> to get this sample up and running in a GCE environment with GCLB used as the
> ManualLB. This is only to enable testing this sample for demo purposes.

---
### Prepare

- Decide on which admin cluster will be used to manage the new user cluster. If
  you don't have one, then create a new admin cluster.
- Ensure you have the correct network setup for [**Manual load balancing** mode](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/manual-lb).
- Ensure the workstation you will be using to run terraform has access to all
  the nodes of the new cluster.
---

### Run Terraform

The steps that follow assumes that you already have this repo cloned locally and
have changed directory to where this samples is:
`<REPO_ROOT_DIR>/anthos-onprem-terraform/abm_user_cluster_manuallb`.

- Make a copy of the `terraform.tfvars.sample` file:

    ```sh
    cp terraform.tfvars.sample terraform.tfvars
    ```

- Fill in the `terraform.tfvars` file with values appropriate to your
  environment:
  - **`project_id`**: The GCP project of the admin cluster and where the user
    cluster will be created.

  - **`region`**: The Google Cloud region in which the Anthos On-Prem API
    runs.
  - **`admin_cluster_name`**: The name of the admin cluster that will manage
    the new user cluster.
  - **`cluster_name`**: The name to given to the new user cluster that will be
    created.
  - **`bare_metal_version`**: The Anthos clusters on bare metal version for
    your user cluster. This must be same as the admin cluster version or one
    minor version less, at most. It cannot be higher in any case - minor or
    patch.
  - **`control_plane_ips`**: IP addresses of the nodes that will be part of
    the control plane of the cluster.
  - **`worker_node_ips`**: IP addresses of the nodes that will be part of
    the worker node pools of the cluster.
  - **`control_plane_vip`**: The virtual IP address (VIP) that you have chosen
    to configure on the load balancer for the Kubernetes API server of the
    user cluster.
  - **`ingress_vip`**: The virtual IP address that you have chosen to
    configure on the load balancer for the ingress proxy.
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
