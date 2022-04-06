## Install with Manual Loadbalancer

This guide is an extension to the [all-in-one install guide](one_click_install.md).
The `all-in-one install` is a single run installation which automatically
triggers the complete **Anthos on bare metal** installation when the Terraform
script is run. The default installation sets up Anthos on bare metal to run
using a [bundled loadbalancer](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/bundled-lb).
This means that the loadbalancer and the cluster services are reachable only
from inside one of the GCE VMs _(i.e. Admin workstation, Controlplane nodes, Worker nodes)_
created during the installation process.

While, this setup closely represents how **Anthos on bare metal (ABM)** will be
deployed in an actual enterprise baremetal environment, this is not ideal for
demos. With demo environments we would like to be able to easily reach the
`control plane` and the `ingress` of the Anthos on bare metal cluster without
having to SSH into a jump host.

Thus, this extension _(to the terraform script)_ installs Anthos on bare metal
using the [Manual LB](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/manual-lb)
mode. We use [Google Cloud Loadbalancer](https://cloud.google.com/load-balancing/docs/load-balancing-overview)
as the loadbalancer fronting the Anthos on bare metal cluster.

---

### This new mode of installation creates **two** new Google Cloud Loadbalancers:
1. [TCP Loadbalancer](https://cloud.google.com/load-balancing/docs/ssl): this is
   the loadbalancer configured to front the `API Server (Controlplane)` of the
   ABM cluster. You can reach the `API Server` of your cluster via the
   `External IP Address` associated to this loadbalancer.
   
2. [HTTP(S) Loadbalancer](https://cloud.google.com/load-balancing/docs/https):
   this is the loadbalancer configured to front the `Ingress Service` of the ABM
   cluster. You can reach the `Kubernetes Services` of your cluster via the
   `External IP Address` associated to this loadbalancer.
 
<p align="center">
  <img src="images/gcp_lbs.png">
  <em>
    </br>
    (click image to enlarge)
  </em>
</p>

---

### Complete deployment architecture

<p align="center">
  <img src="images/picture here.png">
  <em>
    </br>
    (click image to enlarge)
  </em>
</p>

---

### Pre-requisites
- This guide has the [same pre-requisites as the quickstart guide](/anthos-bm-gcp-terraform/README.md#pre-requisites)

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

> **Note:** Alternative to changing the variables file you may run the following commands
> using the `-var 'mode=manuallb'` flag

```sh
# terraform.tfvars file
...
mode             = "manuallb"
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

***The `apply` command sets up the Compute Engine VM based bare metal infrastructure. This can take a few minutes (approx. 5-8 mins) for the VMs to get setup.***

---
### Verify installation

The Terraform script sets up the GCE VM infrastructure, configures the GCP resources required for the Loadbalancers and finally triggers the installation of Anthos on bare metal on the provisioned VMs. The installation is triggered from inside the _admin workstation_ VM.

Upon completion the Terraform script will print the following output to the console.
```sh
################################################################################
#          SSH into the admin host and check the installation progress         #
################################################################################

> gcloud compute ssh tfadmin@cluster1-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
> tail -f ~/install_abm.log

################################################################################
```

> **Note:** You will notice that the output of the terraform script also has the
> **Public IP addresses** of the `Controlplane` and `Ingress` loadbalancers. You
> must wait until the Anthos on bare cluster installation is complete before
> being able to access the cluster through them.

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

You can find your cluster's `kubeconfig` file on the admin machine in the
`bmctl-workspace` directory. Since the `API Server` of the cluster is exposed
via the GCP Loadbalancer, the `kubeconfig` file is configured to use the
**Public IP Address** of the loadbalancer. Thus, you can copy the `kubeconfig`
file to your local workstation and interact with the cluster using `kubectl`. 

To verify your deployment, complete the following steps:

1. Copy the contents of `kubeconfig` file to your workstation.
    ```sh
    ```

2. Set the `KUBECONFIG` environment variable with the path to the cluster's configuration file to run `kubectl` commands on the cluster.
    ```sh
    export KUBECONFIG=<PATH_TO_ANTHOS_BAREMETAL_CLUSTER_KUBECONFIG>
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