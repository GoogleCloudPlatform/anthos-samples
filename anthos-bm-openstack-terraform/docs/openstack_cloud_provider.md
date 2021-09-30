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
  <img src="images/openstack-setup.png" width="550">
  <img src="images/logged-in-k8s.png">
</p>

> **Note:** If your have a working Anthos on Bare Metal cluster running on
> OpenStack whose set up doesn't exactly match the diagram above, you should
> still be able to use this guide with minor tweaks to match your environment.
>
---
#### 1) Source your `openrc` file.
```sh
source <PATH_TO_OPENRC_FILE>/openrc.sh
```

> **Note:** If you followed the [OpenStack on GCE guide](install_openstack_on_gce.md#43-access-the-openstack-api-server-via-the-external-ip-of-the-gce-instance)
> & the [quick start guide](quickstart.md#12-download-the-openrc-file) then your
> `openrc` file might be named `admin-openrc.sh`

#### 2) Setup CA certificate configuration for the OpenStack CLI.
```sh
export OS_CACERT=<PATH_TO_OPENRC_FILE>/openstack-ca.crt
```
> **Note:** If you followed the OpenStack on GCE guide [step-4.6](install_openstack_on_gce.md#46-download-the-ca-certificate),
> then the CA certificate in your workstation should be at:</br>
>  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;**`export OS_CACERT=~/.ssh/openstack-ca.crt`**

#### 3) _(Optional)_ Create a VPN tunnel to route traffic to the **OpenStack** APIs
This step is required only if you are working on an OpenStack environment
provisioned by following the

#### 4) Verify that the OpenStack CLI client is working.
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
| 0efcdfe9c3124331b1cdf40d1c9da509 | RegionOne | keystone     | identity      | True    | public    | https://10.128.0.2:5000                     |
| 13a1b08e1cde484094aec1bf932be43c | RegionOne | cinderv3     | volumev3      | True    | public    | https://10.128.0.2:8776/v3/%(tenant_id)s    |
| 17285e1785e8439c9d204cfe2fa74437 | RegionOne | cinderv3     | volumev3      | True    | internal  | http://172.29.236.100:8776/v3/%(tenant_id)s |
| 269407b75c6546db9bfa82cd7e52c7c0 | RegionOne | cinderv3     | volumev3      | True    | admin     | http://172.29.236.100:8776/v3/%(tenant_id)s |
| ...                                                                                                                                             |
| ...                                                                                                                                             |
| ...                                                                                                                                             |
+----------------------------------+-----------+--------------+---------------+---------+-----------+---------------------------------------------+
```



```sh
cd <PATH_TO_REPOSITORY>/anthos-samples/anthos-bm-openstack-terraform
```

```sh
# change this if you used something else in Step-2.2 of the quick start guide
export SSH_KEY_NAME="abmNodeKey"
```

```sh
# fetch the ip address using the Terraform output
export FLOATING_IP=$(terraform output admin_ws_public_ip | tr -d '"')

# fetch the ip address using the OpenStack API
export FLOATING_IP=$(openstack floating ip list --tags=abm_ws_floatingip -f json | jq -c '.[]."Floating IP Address"' | tr -d '"')

# echo and note down the floating IP
echo $FLOATING_IP
```

```sh
# if you followed the OpenStack on GCE guide then the file will be named `admin-openrc.sh`
scp -o IdentitiesOnly=yes -i ~/.ssh/${SSH_KEY_NAME} <PATH_TO_DOWNLOADED_OPENRC>/openrc.sh ubuntu@$FLOATING_IP:~

# SSH into the admin workstation
ssh -o IdentitiesOnly=yes -i ~/.ssh/${SSH_KEY_NAME} ubuntu@$FLOATING_IP

# switch to the "abm" user
sudo -u abm -i

# copy the initialization scripts into the "abm" user's $HOME
cp /home/ubuntu/*openrc.sh ./
```


```sh
source ./openrc.sh
```
> OS_CACERT

```sh
# you can use this one line command if you have `jq` CLI tool installed
# if not use the "openstack network list --name=public" command to get the ID
export PUBLIC_NETWORK_ID=$(openstack network list --name=public -f json | jq -c '.[]."ID"' | tr -d '"')

# make sure you have the PUBLIC_NETWORK_ID environment variable is set
echo $PUBLIC_NETWORK_ID
```

```sh
export ABM_NETWORK_SUBNET_ID=$(openstack network list --name=abm-network -f json | jq -c '.[]."Subnets"' | jq -c '.[]' | tr -d '"')

echo $ABM_NETWORK_SUBNET_ID
```

```sh
cat > cloud.conf << EOF
[Global]
auth-url=$OS_AUTH_URL
username=$OS_USERNAME
password=$OS_PASSWORD
region=RegionOne
tenant-name=admin
domain-id=default
# uncomment if you are using self-signed cert or specify with ca-file arg
tls-Insecure=true

[LoadBalancer]
use-octavia=true
# this should be private network subnet where vip is allocated on
subnet-id=${ABM_NETWORK_SUBNET_ID}
# this is generally our public network
floating-network-id=${PUBLIC_NETWORK_ID}

[BlockStorage]
bs-version=v2
EOF
```

```sh

export KUBECONFIG=~/bmctl-workspace/openstack-1/openstack-1-kubeconfig
kubectl create secret -n kube-system generic cloud-config --from-file=cloud.conf

kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml


```
