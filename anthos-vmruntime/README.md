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

The following command uses the `virtctl` plugin of the `kubectl` CLI.
Alternatively, you can also create the VM using **KRM** definitions in a yaml.
The [pos-vm.yaml](/pos-vm.yaml) is another way of expressing the creation of a
VM. Thus, you can also copy this yaml definition into the admin workstation and
create the VM using `kubectl apply -f pos-vm.yaml`.

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
> **Note:** After you run `kubectl virt create vm pos-vm`, the CLI would have
> created a yaml file named after the vm (`pos-vm.yaml`). You can inspect it to
> see the definiton of the `VirtualMachine` and `DataVolume`.  

---
#### Check the VM creation status

Creation of the VM requires two resources to be created: `DataVolume` and
`VirtualMachine`. `DataVolume` is the _persistent disk_ where the contents of
the **VM image** is imported into and is made bootable from. `VirtualMachine` is
the **VM template** created based off of the image. The `DataVolume` is mounted
into the `VirtualMachine` before the VM is booted up. Creation of a
`VirtualMachine`, automatically triggers the creation of a
`VirtualMachineInstance` resource which represents a _RUNNING_ instance of a VM.

- Check the status of the `DataVolume`.
    ```sh
    # you can use dv and datavolume interchangeably
    kubectl get dv
    ```
    ```sh
    # expected output
    NAME              PHASE             PROGRESS   RESTARTS   AGE
    pos-vm-boot-dv    ImportScheduled   N/A                   8s
    ```
- Check the status of the `VirtualMachine`.
    ```sh
    # you can use vm and virtualmachine interchangeably
    kubectl get vm
    ```
    ```sh
    # expected output
    NAME      AGE     STATUS         READY
    pos-vm    10s     Provisioning   False
    ```
- Check the status of the `VirtualMachineInstance`.
    ```sh
    # you can use vmi and virtualmachineinstance interchangeably
    kubectl get vmi
    ```
    ```sh
    # expected output
    NAME      AGE     PHASE     IP              NODENAME                      READY
    pos-vm2   22m     Pending                                                 False
    ```
- Wait for the **VM image** to be fully imported into the `DataVolume`. You can
  continue to watch the progress while the image is being imported.
    ```sh
    # you can use dv and datavolume interchangeably
    kubectl get dv -w

    NAME              PHASE              PROGRESS   RESTARTS   AGE
    pos-vm-boot-dv   ImportInProgress   0.00%                 14s
    ...
    ...
    pos-vm-boot-dv   ImportInProgress   0.00%                 31s
    pos-vm-boot-dv   ImportInProgress   1.02%                 33s
    pos-vm-boot-dv   ImportInProgress   1.02%                 35s
    ...
    ```

    Once the import is complete and the `DataVolume` has been created, the output
    would change as follows.
    ```sh
    kubectl get dv

    NAME              PHASE             PROGRESS   RESTARTS   AGE
    pos-vm-boot-dv    Succeeded         100.0%                22m18s
    ```
    > **Note:** The import time is dependent on the size of the VM image being used.
    > The GCE VM image we have used here is **~11GB**s and can take upto **35 mins**
    > to be fully imported.
- Verify that the `VirtualMachine` and `VirtualMachineInstance` resources are **RUNNING**.
    ```sh
    kubectl get vm

    NAME      AGE     STATUS         READY
    pos-vm    40m     Running        True
    ```
    ```sh
    kubectl get vmi

    NAME      AGE     PHASE     IP              NODENAME                      READY
    pos-vm    40m     Running   192.168.3.250   kubevirt-cluster-abm-w1-001   True
    ```
---
#### Verify access into the VM

- Connect to the VM console. Press the `return ⏎` key
  once you see the `Successfully connected to pos-vm ...` message.
    ```sh
    kubectl virt console pos-vm
    ```
    ```sh
    # expected output
    Successfully connected to pos-vm console. The escape sequence is ^]

    pos-from-public-image login:
    ```
- Use the following default `username` and `password`.
    ```sh
    pos-from-public-image login: abmuser
    Password: abmworks
    ```
    ```sh
    # expected output
    Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-109-generic x86_64)

    ...
    
    System load:  1.63               Processes:               135
    Usage of /:   12.2% of 73.10GB   Users logged in:         0
    Memory usage: 23%                IPv4 address for enp1s0: 10.0.2.2
    Swap usage:   0%

    ...

    Apr 25 15:52:11 pos-from-public-image systemd[1]: Created slice User Slice of UID 1003.
    Apr 25 15:52:11 pos-from-public-image systemd[1]: Starting User Runtime Directory /run/user/1003...
    Apr 25 15:52:11 pos-from-public-image systemd[1]: Finished User Runtime Directory /run/user/1003.
    Apr 25 15:52:11 pos-from-public-image systemd[1]: Starting User Manager for UID 1003...
    ...
    Apr 25 15:52:14 pos-from-public-image systemd[1]: Started User Manager for UID 1003.
    Apr 25 15:52:14 pos-from-public-image systemd[1]: Started Session 1 of user abmuser.
    To run a command as administrator (user "root"), use "sudo <command>".
    See "man sudo_root" for details.

    abmuser@pos-from-public-image:~$
    ```
    > **Note:** You may see additional logs from the `systemd` services when you
    > connect to the VM console for the first time. Give it a few minutes and
    > press the `return ⏎` key get the login prompt. 
- To exit out of the VM, first you have to exit out of the login shell session.
  Then, you have to exit out of the VM console.
    ```sh
    abmuser@pos-from-public-image:~$ exit
    ```
    ```sh
    # expected output
    logout
    Apr 25 15:56:11 pos-from-public-image systemd[1]: Starting Cleanup of Temporary Directories...
    Apr 25 15:56:11 pos-from-public-image systemd[1]: serial-getty@ttyS0.service: Succeeded.
    ...
    Apr 25 15:56:11 pos-from-public-image systemd[1]: Finished Cleanup of Temporary Directories.

    Ubuntu 20.04.4 LTS pos-from-public-image ttyS0

    pos-from-public-image login:
    ```
- To exit the console connection use `Ctrl + ]` (`^]`). You could have also used
  this escape sequence (`^]`) to directly exit out from the VM login shell.
---
#### Create a new `Kubernetes Service` that will route traffic to the VM

The [installation guide](/anthos-bm-gcp-terraform/docs/manuallb_install.md)
based on which the Anthos on bare metal cluster was setup, automatically creates
an [`Ingress` resource named `pos-ingress`](https://github.com/GoogleCloudPlatform/anthos-samples/blob/kubevirt-guide/anthos-bm-gcp-terraform/resources/manifests/pos-ingress.yaml).
This resource routes the traffic from the public IP address of the Ingress
loadbalancer to the _api server service_ of the Point Of Sale sample application.

```sh
kubectl describe ingress/pos-ingress
```
```sh
# expected output
Name:             pos-ingress
Labels:           <none>
Namespace:        default
Address:          34.117.58.199
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /   api-server-svc:8080 (<error: endpoints "api-server-svc" not found>)
Annotations:  <none>
Events:       <none>
```

Note that there are erros indicating that the `api-server-svc` was not found.
This is because we deleted the resources created by default in [an earlier step](#cleanup-the-resources-created-by-default-in-the-installation-guide).
We will have to re-create this `Service` pointing to the
`VirtualMachineInstance`. This way, we can get the `Ingress` working once again
and reach the sample application inside the VM via the `Ingress` LB IP.

Copy the [`pos-service.yaml`](pos-service.yaml) file into the admin workstation
VM. Then, update the file to include the IP address of the VM as a service
`Endpoint`. Finally apply the changes to the cluster.

```sh
# you should have the pos-service.yaml copied into the admin workstation

# retrieve the IP address of the virtual machine we created
export VM_IP=$(kubectl get vmi/pos-vm -o jsonpath='{.status.interfaces[0].ipAddress}')

# update the pos-service.yaml with the virtual machine's IP address
sed -i "s/VM_IP/${VM_IP}/g" pos-service.yaml

# apply the changes to the Anthos on bare metal cluster
kubectl apply -f pos-service.yaml
```
```sh
# expected output
service/api-server-svc created
endpoints/api-server-svc created
```

Now, retrieve the public IP address of the `Ingress LB` and try accessing it via
a browser.

```sh
INGRESS_IP=$(kubectl get ingress/pos-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $INGRESS_IP
```
```sh
34.117.58.199 # you might have a different IP address
```