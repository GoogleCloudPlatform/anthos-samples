## All in one install

This guide is an alternative to the [quickstart guide](quickstart.md) for installing Anthos
on bare metal. The quickstart is split into two phases to ensure that the readers can clearly
distinguish between the two important steps required for the installation: ***Setting up
the GCE VMs to emulate a bare metal environment*** and ***Installing Anthos on bare metal
inside the VMs***.

The following guide coalesces the two steps into a single terraform execution. Thus, running
the terraform script _(as explained here)_ automatically triggers the Anthos on bare metal
installation inside the created GCE VMs. Upon completing this guide you can SSH into the
_admin workstation_ GCE VM, and monitor the status of the Anthos on bare metal installation.

We can force the terraform run to continue onto the Anthos on bare metal installation
_(after creating the GCE VMs)_ by setting the variable `mode` to `install`.

### Pre-requisites
- This guide has the [same pre-requisites as the quickstart guide](/anthos-bm-gcp-terraform/README.md#pre-requisites).

### Step by step guide

1. Clone this repo into the workstation from where the rest of this guide will be followed.
   Move into the directory of this sample.
```sh
cd anthos-bm-gcp-terraform/
```

2. Create a `terraform.tfvars` file from the sample input variables file
```sh
cp terraform.tfvars.sample terraform.tfvars
```

3. Update the `terraform.tfvars` file to include variables specific to your environment
```sh
# terraform.tfvars file

project_id       = "<GOOGLE_CLOUD_PROJECT_ID>"
region           = "<GOOGLE_CLOUD_REGION_TO_USE>"
zone             = "<GOOGLE_CLOUD_ZONE_TO_USE>"
credentials_file = "<PATH_TO_GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE>"
```

4. Add the `mode` variable to the `terraform.tfvars` file
```sh
# terraform.tfvars file
...
mode             = "install"
...
```

5. Navigate to the root directory of this sample and initialize Terraform
```sh
terraform init
```

5. Create a _Terraform_ execution plan
```sh
terraform plan
```

6. Apply the changes described in the _Terraform_ script
```sh
terraform apply
```
> **Note:** When prompted to confirm the Terraform plan, type 'Yes' and enter

***The `apply` command sets up the Compute Engine VM based bare metal infrastructure. This can take a few minutes (approx. 3-5 mins) for the VMs to get setup.***

---
### Verify installation

As explained earlier, the Terraform script sets up the GCE VM infrastructure and also
triggers the installation of Anthos on bare metal on the provisioned VMs. The installation
is triggered from inside the _admin workstation_ VM.

Upon completion the Terraform script will print the following output to the console.
```sh
################################################################################
#          SSH into the admin host and check the installation progress         #
################################################################################

> gcloud compute ssh tfadmin@cluster1-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
> tail -f ~/install_abm.log

################################################################################
```

Use these commands to SSH into the _admin workstation_ and to monitor the installation status.
Once it is complete the output in the log file will look as follows:

> **Note:** The installation process for Anthos on bare metal can take up to 15
> minutes.

```sh
...
[2022-03-22 23:21:12+0000] Moving admin cluster resources to the created admin cluster
[2022-03-22 23:21:18+0000] Waiting for node update jobs to finish OK
[2022-03-22 23:22:48+0000] Flushing logs... OK
[2022-03-22 23:22:48+0000] Deleting bootstrap cluster... OK

Anthos on bare metal installation complete!
Run [export KUBECONFIG=/home/tfadmin/bmctl-workspace/cluster1/cluster1-kubeconfig] to set the kubeconfig
Run the [/home/tfadmin/login.sh] script to generate a token that you can use to login to the cluster from the Google Cloud Console
```
---
### Interacting with the Baremetal cluster

You can find your cluster's `kubeconfig` file on the admin machine in the `bmctl-workspace` directory. To verify your deployment, complete the following steps from inside the _admin workstation_.

1. Set the `KUBECONFIG` environment variable with the path to the cluster's configuration file to run `kubectl` commands on the cluster.
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

- Follow the [same cleanup steps as the quickstart guide](quickstart.md#cleanup).
