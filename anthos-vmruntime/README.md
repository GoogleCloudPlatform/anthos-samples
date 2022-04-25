# Anthos VM Runtime for running VM workloads

The following guide explains how you can run a VM workload in your Anthos on
bare metal clusters. All Anthos on bare metal clusters since version 1.10
comes with the `Anthos VMRuntime` custom resource definition installed. The
`Anthos VMRuntime` is backed by the [`KubeVirt`](https://kubevirt.io/) project.

We will use a GCE VM as the base VM workload that we eventually migrate into
an Anthos on bare metal cluster. The process for VMs running in any other
virtualization platform should be almost the same.

### The guide has the following highlevel steps:

> You may skip some of these steps if you already have the necessary setup. For
example if you already have an Anthos on bare metal cluster running, then you
can skip the first step.

  - Deploy an Anthos on bare metal cluster
  - Deploy a `MySQL` container that the VM workload will connect to
  - Enable the `Anthos VMRuntime` on the cluster
  - Create a new VM in the Anthos on bare metal cluster referencing a publicly avaiable GCE VM image
  - Create a new `Kubernetes Service` that will route traffic to the created VM
  - Access the VM based sample application via the `Ingress Loadbalancer` of the Anthos on bare metal cluster

To create a VM in the Anthos on bare metal cluster, you need a VM image
_(accepted formats are: `qcow2` or `raw`)_ similar to container images for Pods. 
This image must be hosted in a repository that can be reached from your Anthos
on bare metal cluster nodes. For the purpose of this guide, we have already
created an image of a GCE VM and made it publicly accesible.

---
#### Pre-requisites
- 

---
#### Deploy an Anthos on bare metal cluster

> **Note:** If you already have an Anthos on bare metal cluster then you can
> skip this step. If you do skip, then note that some future steps also might
> not be relavant to your setup.

You can deploy an Anthos on barel metal cluster by following
[this guide](/anthos-bm-gcp-terraform/docs/manuallb_install.md). This sets up an
Anthos on bare metal cluster inside GCE VMs using the [`Manual LB` mode](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/manual-lb). We use [Google Cloud Loadbalancers](https://cloud.google.com/load-balancing/docs/load-balancing-overview) as the manually configured loadbalancers to ensure we
can reach the VM workloads running inside our cluster at the end of this guide.

The steps that follow assumes that you have SSH'ed into the admin workstation
that was created during the Anthos on bare metal cluster installation process.
They also assume that you have configured the `KUBECONFIG` environment variable
inside the admin workstation so that you can access the control plane of your
cluster using `kubectl`.

```sh
# these are example commands from the installation guide

# SSH into the admin workstation 
gcloud compute ssh tfadmin@cluster1-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>

# set the KUBECONFIG environment variable
export KUBECONFIG=/home/tfadmin/bmctl-workspace/cluster1/cluster1-kubeconfig
```
---
#### Cleanup the resources created by default in the installation guide

```sh
# delete the sample application pods in the default namespace
kubectl delete pods --all -n default

# delete the sample application services in the default namespace
kubectl delete svc api-server-svc inventory-svc payments-svc
```
---
#### Deploy a `MySQL` container that the VM workload will connect to

Copy the [mysql-db.yaml](mysql-db.yaml) file into the admin workstation and
apply it to the cluster.

```sh
kubectl apply -f mysql-db.yaml
```
---
#### Enable the `Anthos VMRuntime` on the cluster

The `Anthos VMRuntime` custom resource definition (CRD) is part of all Anthos on
bare metal clusters since version `1.10`. An instance of the `VMRuntime` custom
resource is already created upon installation. However, it is `disabled` by
default. Thus, you have to `enable` it to be able to create and manage VMs using
the `Anthos VMRuntime`.

The following command would open the resource specification for the `VMRuntime`
instance in the default editor of your shell session. Update the specification
by setting the `spec.enabled` field to `true`.
```sh
kubectl edit vmruntime
```
 You can also copy the [vmruntime.yaml](vmruntime.yaml)
file from this repository into your admin workstation and directly apply that
using `kubectl apply -f vmruntime.yaml`.

> **Note:** Optionally, you can set the `spec.useEmulation` field to `true`.
> Setting this to true ensures that the VMRuntime makes use of hardware
> virtualization for better performace if your node supports it.
---
####  Install the [`virtctl`](https://kubevirt.io/user-guide/operations/virtctl_client_tool/) plugin for `kubectl`

> **Note:** The path for the ServiceAccount key is based on the install guide
> linked previously. If you did not follow that guide to set up your Anthos on
> bare metal cluster, then it may be different for you.
```sh
# set the environment variable to the service account key used to access GCP
export GOOGLE_APPLICATION_CREDENTIALS="/root/bm-gcr.json"

# install the virtctl plugin using the bmctl CLI tool
sudo -E bmctl install virtctl
```

```sh
# expected output
Please check the logs at bmctl-workspace/log/install-virtctl-20220422-232525/install-virtctl.log
```

You can verify installation by issueing `kubectl virt` in your console.

```sh
> kubectl virt
Available Commands:
  addvolume         add a volume to a running VM
  completion        generate the autocompletion script for the specified shell
  config            Config subcommands.
  console           Connect to a console of a virtual machine instance.
  create            Create subcommands.
  delete            Delete  subcommands.
...
...
```
---
####  Create a new VM in the Anthos on bare metal cluster

Here we use an already created and [publicly hosted `qcow2` image](https://storage.googleapis.com/abm-vm-images).
This image was created based off of a GCE VM. Before the image was created the
[Point-of-Sale](https://github.com/GoogleCloudPlatform/point-of-sale) sample
application was installed inside the GCE VM. Further, a `systemd` service was
configured to start the sample application when the VM boots up. You can see the
`systemd` service config files in the [pos-systemd-services](pos-systemd-services)
directory.

```sh
kubectl virt create vm pos-vm \
--boot-disk-size=80Gi \
--boot-disk-storage-class=standard \
--cpu=2 \
--image=https://storage.googleapis.com/abm-vm-images/ubuntu-2004-pos.qcow2 \
--memory=4Gi
```

```sh
# expected output
Constructing yaml for vm "pos-vm":
Deployment yaml for vm "pos-vm" is saved to pos-vm.yaml.
Apply yaml for vm "pos-vm"
Creating boot DataVolume "pos-vm-boot-dv"
Creating gvm "pos-vm"
```