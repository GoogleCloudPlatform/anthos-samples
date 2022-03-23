## Quick starter

### Setup the bare metal infrastructure

1. Clone this repo into the workstation from where the rest of this guide will be followed

2. Update the `terraform.tfvars.sample` file to include variables specific to your environment
```
project_id       = "<GOOGLE_CLOUD_PROJECT_ID>"
region           = "<GOOGLE_CLOUD_REGION_TO_USE>"
zone             = "<GOOGLE_CLOUD_ZONE_TO_USE>"
credentials_file = "<PATH_TO_GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE>"
```

3. Rename the `variables` file to default name used by Terraform for the `variables` file:
> **Note:** You can skip this step if you run `terraform apply` with the `-var-file` flag
```sh
mv terraform.tfvars.sample terraform.tfvars
```

4. Navigate to the root directory of this repository initialize it as a Terraform directory
```sh
# this sets up the required Terraform state management configurations, similar to 'git init'
terraform init
```

5. Create a _Terraform_ execution plan
```sh
# compares the state of the resources, verifies the scripts and creates an execution plan
terraform plan
```

6. Apply the changes described in the _Terraform_ script
```sh
# executes the plan on the given provider (i.e: GCP) to reach the desired state of resources
terraform apply
```
> **Note:** When prompted to confirm the Terraform plan, type 'Yes' and enter

***The `apply` command sets up the Compute Engine VM based bare metal infrastructure. This can take a few minutes (approx. 3-5 mins) for the entire bare-metal cluster to be setup.***

---
### Deploy an Anthos cluster

After the Terraform execution completes you are ready to deploy an Anthos cluster.

1. SSH into the admin host
```sh
gcloud compute ssh tfadmin@cluster1-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
```

2. Install the Anthos cluster on the provisioned Compute Engine VM based bare metal infrastructure
```sh
sudo ./run_initialization_checks.sh && \
sudo bmctl create config -c cluster1 && \
sudo cp ~/cluster1.yaml bmctl-workspace/cluster1 && \
sudo bmctl create cluster -c cluster1
```
---

Running the commands from the Terraform output starts setting up a new Anthos cluster. This includes checking the initialization state of the nodes, creating the admin and user clusters and also registering the cluster with Google Cloud using [Connect](https://cloud.google.com/anthos/multicluster-management/connect/overview). The whole setup can take up to 15 minutes. You see the following output as the cluster is being created:

> **Note:** The logs for checks on node initialization has been left out. They appear before the following logs from Anthos setup

```sh
Created config: bmctl-workspace/cluster1/cluster1.yaml
Creating bootstrap cluster... OK
Installing dependency components... OK
Waiting for preflight check job to finish... OK
- Validation Category: machines and network
        - [PASSED] 10.200.0.3
        - [PASSED] 10.200.0.4
        - [PASSED] 10.200.0.5
        - [PASSED] 10.200.0.6
        - [PASSED] 10.200.0.7
        - [PASSED] gcp
        - [PASSED] node-network
Flushing logs... OK
Applying resources for new cluster
Waiting for cluster to become ready OK
Writing kubeconfig file
kubeconfig of created cluster is at bmctl-workspace/cluster1/cluster1-kubeconfig, please run
kubectl --kubeconfig bmctl-workspace/cluster1/cluster1-kubeconfig get nodes
to get cluster node status.
Please restrict access to this file as it contains authentication credentials of your cluster.
Waiting for node pools to become ready OK
Moving admin cluster resources to the created admin cluster
Flushing logs... OK
Deleting bootstrap cluster... OK
```

---
### Verify and interacting with the Baremetal cluster

You can find your cluster's `kubeconfig` file on the admin machine in the `bmctl-workspace` directory. To verify your deployment, complete the following steps

1. SSH into the admin host _(if you are not already inside it)_:
```sh
# You can copy the command from the output of Terraform run from the previous step
gcloud compute ssh tfadmin@cluster1-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
```

2. Set the `KUBECONFIG` environment variable with the path to the cluster's configuration file to run `kubectl` commands on the cluster.
```sh
export CLUSTER_ID=cluster1
export KUBECONFIG=$HOME/bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID-kubeconfig
kubectl get nodes
```

You should see the nodes of the cluster printed, _similar_ to the output below:
```sh
NAME          STATUS   ROLES    AGE   VERSION
cluster1-abm-cp1-001   Ready    master   17m   v1.18.6-gke.6600
cluster1-abm-cp2-001   Ready    master   16m   v1.18.6-gke.6600
cluster1-abm-cp3-001   Ready    master   16m   v1.18.6-gke.6600
cluster1-abm-w1-001    Ready    <none>   14m   v1.18.6-gke.6600
cluster1-abm-w2-001    Ready    <none>   14m   v1.18.6-gke.6600
```

#### Interacting with the cluster via the GCP console

During the setup process, your cluster will be auto-registered in Google Cloud using [Connect](https://cloud.google.com/anthos/multicluster-management/connect/overview). In order to interact with the cluster from the GCP console you must first ***login*** to the cluster.

The [Logging into the Anthos bare metal cluster](login.md) explains how you can do it.

---
### Cleanup

You can cleanup the cluster setup in two ways:

#### 1. Using Terraform

- First deregister the cluster before deleting all the resources created by Terraform
  ```sh
  # SSH into the admin host
  gcloud compute ssh tfadmin@cluster1-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>

  # Reset the cluster
  export CLUSTER_ID=cluster1
  export KUBECONFIG=$HOME/bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID-kubeconfig
  sudo bmctl reset --cluster $CLUSTER_ID

  # logout of the admin host
  exit
  ```

- Then, use Terraform to delete all resources.
  ```sh
  # to be run from the root directory of this repo
  terraform destroy --auto-approve
  ```

#### 2. Delete the entire Google Cloud project
- Directly [delete the project](https://console.cloud.google.com/cloud-resource-manager) from the console
