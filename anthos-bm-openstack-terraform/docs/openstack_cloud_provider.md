## Configure the OpenStack Cloud Provider for Kubernetes

This guide explains how to configure the [**OpenStack Cloud Provider for Kubernetes**](https://github.com/kubernetes/cloud-provider-openstack) to use the [OpenStack LBaaS](https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html)
for exposing Kubernetes Services.

---
### Pre-requisites

***The guide assumes the following:***
1. You already have an environment with [OpenStack Ussuri](https://releases.openstack.org/ussuri/index.html) or similar deployed with [LBaaS v2](https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html) configured and
functional.
     - _either your own OpenStack deployment or one created via the [OpenStack on Google Compute Engine](/anthos-bm-openstack-terraform/docs/install_openstack_on_gce.md) guide_
     - _if you have the setup from the [OpenStack on GCE](/anthos-bm-openstack-terraform/docs/install_openstack_on_gce.md)
      guide then make sure that you have a VPN tunnel set up in a separate
      terminal window using `sshuttle` as shown in [**Step-4.5**](install_openstack_on_gce.md#45-create-a-vpn-tunnel-to-route-traffic-to-the-openstack-apis)_
      </br>
1. You have configured and installed Anthos on Bare Metal in your OpenStack environment.
    - _either installed manually or by completing the [Install Anthos Bare Metal on OpenStack with Terraform](/anthos-bm-openstack-terraform/docs/quickstart.md) quick start guide_
---

<!-- If you have completed the *Install Anthos Bare Metal on OpenStack with Terraform*
guide then you would have the following in your workstation:
- The `openrc.sh` file used by the OpenStack CLI client downloaded.
- The **password** for the OpenStack user who generated the above `openrc.sh` stored somewhere.
- The public and private key files for the SSH key named `abmNodeKey` stored at `~/.ssh`.

> **Note:** The name of the SSH key can be different based on what you used for
> `SSH_KEY_NAME` in [Step-2.2](/anthos-bm-openstack-terraform/docs/quickstart.md#22-create-and-upload-ssh-keys-to-be-used-by-the-openstack-vms) of the quick start

In addition: -->

If you completed the [quick start guide](/anthos-bm-openstack-terraform/docs/quickstart.md)
you should already have the expected setup in your OpenStack environment to
complete this section. However, if you **manually** configured OpenStack and
installed Anthos on Bare Metal, then ensure your environment meets the following
expectation before continuing. Your OpenStack deployment:
- Should have an infrastructure set up similar to what is shown below.
- Should have three OpenStack VMs that match the [VM description table](quickstart.md)
  on the quick start guide.
- Those OpenStack VMs should be hosting an Anthos on Bare Metal cluster.
- That cluster should be **registered** and **logged-in** to GCP as shown below _(see [quick start step-6](quickstart.md#6-verifying-installation-and-interacting-with-the-anthos-on-bare-metal-cluster) for how-to)_.
<p align="center">
  <img src="images/openstack-setup.png" width="650">
  <img src="images/logged-in-k8s.png">
</p>

> **Note:** _If your have a working Anthos on Bare Metal cluster running on
> OpenStack whose set up doesn't exactly match the diagram above, you should
> still be able to use this guide with minor tweaks to match your environment._
>
---
#### 1) Source your `openrc` file.
```sh
source <PATH_TO_OPENRC_FILE>/openrc.sh
```

> **Note:** _If you followed the [OpenStack on GCE guide](install_openstack_on_gce.md#43-access-the-openstack-api-server-via-the-external-ip-of-the-gce-instance)
> & the [quick start guide](quickstart.md#12-download-the-openrc-file) then your
> `openrc` file might be named `admin-openrc.sh`_

#### 2) Setup CA certificate configuration for the OpenStack CLI.
```sh
export OS_CACERT=<PATH_TO_OPENRC_FILE>/openstack-ca.crt
```
> **Note:** _If you followed the OpenStack on GCE guide [step-4.6](install_openstack_on_gce.md#46-download-the-ca-certificate),
> then the CA certificate in your workstation should be at:_</br>
>  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;**`export OS_CACERT=~/.ssh/openstack-ca.crt`**

#### 3) Verify that the OpenStack CLI client is working.
```sh
# see if you are able to list the endpoints from the OpenStack server
openstack endpoint list
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
+----------------------------------+-----------+--------------+---------------+---------+-----------+---------------------------------------------+
| ID                               | Region    | Service Name | Service Type  | Enabled | Interface | URL                                         |
+----------------------------------+-----------+--------------+---------------+---------+-----------+---------------------------------------------+
| 03e84f47ebbe435cb87865da0b780d28 | RegionOne | placement    | placement     | True    | public    | https://10.128.0.2:8780                     |
| 067e51258831471e9d936f66c24353e8 | RegionOne | placement    | placement     | True    | admin     | http://172.29.236.100:8780                  |
| 0c1e5ae42269481a8aed9caf6cb7b456 | RegionOne | keystone     | identity      | True    | admin     | http://172.29.236.100:5000                  |
| ...                                                                                                                                             |
| ...                                                                                                                                             |
| ...                                                                                                                                             |
+----------------------------------+-----------+--------------+---------------+---------+-----------+---------------------------------------------+
```

#### 4) Get the ID of the public network in OpenStack
This is the publicly accessible network in your OpenStack deployment from which
`Floating IP`s are allocated. It is from this network the `LoadBalancer` IPs
for the Kubernetes services will be allocated.

> **Note:** _The following command assumes that you have an OpenStack
> environment similar to what is created in the [OpenStack on GCE](/anthos-bm-openstack-terraform/docs/install_openstack_on_gce.md) guide. If your environment was set up
> differently, select the appropriate `public network`._
```sh
# you can use this one line command if you have `jq` CLI tool installed
# if not use the "openstack network list --name=public" command to get the ID
export PUBLIC_NETWORK_ID=$(openstack network list --name=public -f json | jq -c '.[]."ID"' | tr -d '"')

# make sure you have the PUBLIC_NETWORK_ID environment variable is set
echo $PUBLIC_NETWORK_ID
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
8c30b34a-1f26-4ad5-9c4d-d4f8f286853b
```

#### 5) Get the ID of the subnetwork connecting the Anthos on Bare Metal VMs in OpenStack
This is the subnet on the private network in your OpenStack deployment from
which `IP`s are allocated for the VMs running Anthos on Bare Metal.

> **Note:** _The following command assumes that the network for the  Anthos on
> Bare Metal cluster VMs were created using the Terraform scripts from the
> [Install Anthos Bare Metal on OpenStack with Terraform](quickstart.md#3-configure-and-execute-terraform)
> guide. If your environment was set up differently select an appropriate
> `subnetwork`._
```sh
# you can use this one line command if you have `jq` CLI tool installed; if not
# use the "openstack network list --name=abm-network" command to get the subnetwork's ID
export ABM_NETWORK_SUBNET_ID=$(openstack network list --name=abm-network -f json | jq -c '.[]."Subnets"' | jq -c '.[]' | tr -d '"')

# make sure you have the ABM_NETWORK_SUBNET_ID environment variable is set
echo $ABM_NETWORK_SUBNET_ID
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
33071a29-4fc9-4c8b-9e7a-84f81c97faa8
```

#### 6) Get the floating IP of the admin workstation in OpenStack
We fetch the IP address of the **admin workstation** to SSH into this VM and
configure the **OpenStack Cloud Provider**.

> **Note:** _The following command assumes that the admin workstation was
> created using the Terraform scripts from the [Install Anthos Bare Metal on OpenStack with Terraform](quickstart.md#3-configure-and-execute-terraform)
> guide. If your environment was set up differently select the IP address of the
> admin host appropriately._

```sh
# you can use this one line command if you have `jq` CLI tool installed; if not
# use the "openstack floating ip list --tags=abm_ws_floatingip" to get the IP
export FLOATING_IP=$(openstack floating ip list --tags=abm_ws_floatingip -f json | jq -c '.[]."Floating IP Address"' | tr -d '"')

# make sure you have the FLOATING_IP environment variable is set
echo $FLOATING_IP
```

```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
172.29.249.131
```

#### 7) Generate the cloud config file that will be used by the OpenStack provider

> **Note:** _The default values for some attributes in the config file (e.g:
> `region`, `tenant-name`, `domain-id`, etc) are all based on the assumption
> that your OpenStack deployment is similar to the one created after following
> the [OpenStack on GCE](install_openstack_on_gce.md) and [Anthos on Bare Metal on OpenStack with Terraform](quickstart.md)
> guides._
>
> _If your environment was set up differently, you have to set the appropriate
> values. For more information about all configuration parameters, see the
> [OpenStack cloud provider docs](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md#config-openstack-cloud-controller-manager)._

```sh
cat > cloud.conf << EOF
[Global]
auth-url=${OS_AUTH_URL}
username=${OS_USERNAME}
password=${OS_PASSWORD}
region=RegionOne
tenant-name=admin
domain-id=default
# this is for using a self-signed cert if your using a CA then comment this line
# and point to the CA certificate using the ca-file arg
tls-Insecure=true

[LoadBalancer]
use-octavia=true
# this is generally the public network on OpenStack
floating-network-id=${PUBLIC_NETWORK_ID}
# this should be private network subnet where vip is allocated for the ABM nodes
subnet-id=${ABM_NETWORK_SUBNET_ID}

[BlockStorage]
bs-version=v2
EOF
```
```yaml
# -----------------------------------------------------
#                Expected File Contents
# -----------------------------------------------------
[Global]
auth-url=https://10.128.0.2:5000
username=admin
password=2db98770cebfa9fbe430200824307460df7ceebed7add35361
region=RegionOne
tenant-name=admin
domain-id=default
# this is for using a self-signed cert if your using a CA then comment this line
# and point to the CA certificate using the ca-file arg
tls-Insecure=true

[LoadBalancer]
use-octavia=true
# this is generally the public network on OpenStack
floating-network-id=8c30b34a-1f26-4ad5-9c4d-d4f8f286853b
# this should be private network subnet where vip is allocated for the ABM nodes
subnet-id=33071a29-4fc9-4c8b-9e7a-84f81c97faa8

[BlockStorage]
bs-version=v2
```

#### 7) Copy the provider configuration into the admin workstation in OpenStack

> **Note:** _The SSH key information used here assumes that you followed the
> steps from the [Anthos on Bare Metal on OpenStack with Terraform](quickstart.md)
> guide to create your OpenStack VMs. You may remove/change it if your VMs were
> created differently._

```sh
# use the same SSH key used when creating the OpenStack VMs
export SSH_KEY_NAME="abmNodeKey"

# copy the cloud.conf file into the admin workstation
scp -o IdentitiesOnly=yes -i ~/.ssh/${SSH_KEY_NAME} ./cloud.conf ubuntu@$FLOATING_IP:~

# SSH into the admin workstation
ssh -o IdentitiesOnly=yes -i ~/.ssh/${SSH_KEY_NAME} ubuntu@$FLOATING_IP

# switch to the "abm" user
sudo -u abm -i

# copy the configuration file into the "abm" user's $HOME
cp /home/ubuntu/cloud.conf ./
```

#### 8) Install the Kubernetes resources for the OpenStack Cloud Provider in your Anthos on Bare Metal Cluster
```sh
# make sure the kubectl client is pointing towards your Anthos on Bare Metal cluster
export KUBECONFIG=~/bmctl-workspace/abm-on-openstack/abm-on-openstack-kubeconfig

# store the provider configurations as a Kubernetes secret
kubectl create secret -n kube-system generic cloud-config --from-file=cloud.conf

# create the necessary roles for the OpenStack provider
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
# create the required role-bindings for the OpenStack provider
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
# create the OpenStack controller manager
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml
```

#### 9) Deploy a sample application Point-Of-Sales application
```sh
kubectl apply -f https://github.com/GoogleCloudPlatform/anthos-samples/blob/main/anthos-bm-openstack-terraform/resources/point-of-sales.yaml
```

#### 10) Exposed the application via service of type Load Balancer
```sh
kubectl apply -f https://github.com/GoogleCloudPlatform/anthos-samples/blob/main/anthos-bm-openstack-terraform/resources/point-of-sales-service.yaml
```
#### 10) Try accessing the service from a browser
```sh
# wait for the external IP to be assigned
kubectl get services
```
