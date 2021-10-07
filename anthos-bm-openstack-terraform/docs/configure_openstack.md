## Provision the OpenStack VMs and network setup using Terraform

This is the first part to the guide for installing Anthos on bare metal in
OpenStack. In this guide, we configure the OpenStack environment
with the minimum requirements for installing Anthos on bare metal. The Terraform
scripts used in this guide create the following VMs in your OpenStack
environment and sets up the expected networking between them.

  | VM Name  | IP Address    | Usage         |
  | ---------| ------------- | ------------- |
  | abm-ws   | 10.200.0.10 ***(private)***<br/>floating IP ***(public)*** | Acts as the **admin workstation** It is used to deploy Anthos on bare metal to the other machines.
  | abm-cp1  | 10.200.0.11   | **Anthos cluster control plane:**. This host runs the Kubernetes control plane and load balancer.
  | abm-w1   | 10.200.0.12   | **Anthos cluster worker node:** This host runs the Kubernetes workloads.

---
### 1. Setup local environment

#### 1.1) Clone this repository

```sh
git clone https://github.com/GoogleCloudPlatform/anthos-samples.git
cd anthos-samples/anthos-bm-openstack-terraform
```

#### 1.2) Download the `openrc` file
You should be able to download it from **OpenStack Web UI**

<p align="center">
  <img src="images/openstack-download-config.png">
</p>

> **Note:** See the official **OpenStack** [docs on how to retrieve an `openrc` file](https://docs.openstack.org/ocata/user-guide/common/cli-set-environment-variables-using-openstack-rc.html)

#### 1.3) Verify access to your OpenStack environment

After you’ve downloaded the `openrc` file source it and verify access the **OpenStack**
APIs and that **load-balancer API** is enabled:

```sh
source <PATH_TO_OPENRC_FILE>/openrc.sh

openstack endpoint list --service=load-balancer
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
+----------------------------------+-----------+--------------+---------------+---------+-----------+----------------------------+
| ID                               | Region    | Service Name | Service Type  | Enabled | Interface | URL                        |
+----------------------------------+-----------+--------------+---------------+---------+-----------+----------------------------+
| 0ffcbddd6d6147c5b70cc70db6c22fad | RegionOne | octavia      | load-balancer | True    | admin     | http://172.29.236.100:9876 |
| 39ec24b9b0e143eeb6ffae19aea06b2f | RegionOne | octavia      | load-balancer | True    | public    | https://10.128.0.2:9876    |
| f3b4da3c47ed454baac2d7988c255cce | RegionOne | octavia      | load-balancer | True    | internal  | http://172.29.236.100:9876 |
+----------------------------------+-----------+--------------+---------------+---------+-----------+----------------------------+
```

---
### 2. Setup OpenStack environment

#### 2.1) Upload Ubuntu 20.04 (Focal Fossa) image to OpenStack
```sh
# download the image from the public Ubuntu image repository
curl -O https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

# upload it to OpenStack
openstack image create ubuntu-2004 \
	--disk-format qcow2 \
   	--container-format bare --public \
   	--file focal-server-cloudimg-amd64.img
```
> **Note:** _This step can take upto ***10 minutes*** to complete. **1 minute** for downloading the image and **9 minutes** to upload it to **OpenStack**_

#### 2.2) Create and upload SSH keys to be used by the OpenStack VMs
```sh
export SSH_KEY_NAME="abmNodeKey"
# generate the key pair
ssh-keygen -t rsa -f ~/.ssh/${SSH_KEY_NAME}

# upload it to OpenStack
openstack keypair create $SSH_KEY_NAME --public-key ~/.ssh/${SSH_KEY_NAME}.pub
```

#### 2.3) Create OpenStack flavors that can be used to create VMs
```sh
openstack flavor create --id 0 --ram 512   --vcpus 1 --disk 10  m1.tiny
openstack flavor create --id 1 --ram 1024  --vcpus 1 --disk 20  m1.small
openstack flavor create --id 2 --ram 2048  --vcpus 2 --disk 40  m1.medium
openstack flavor create --id 3 --ram 4096  --vcpus 2 --disk 80  m1.large
openstack flavor create --id 4 --ram 8192  --vcpus 4 --disk 160 m1.xlarge
openstack flavor create --id 5 --ram 16384 --vcpus 6 --disk 320 m1.jumbo
```

#### 2.4) Verify that resources were created in OpenStack
```sh
openstack image list
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
+--------------------------------------+---------------------+--------+
| ID                                   | Name                | Status |
+--------------------------------------+---------------------+--------+
| 9afa8795-223d-4a77-80d3-12c153f0fb3e | amphora-x64-haproxy | active |
| 7536b9f1-44ef-40e3-bdd5-82badba4c77f | cirros              | active |
| 4188935a-9025-4f80-b1f5-8012bc553b20 | ubuntu-2004         | active |
+--------------------------------------+---------------------+--------+
```

```sh
openstack keypair list
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
+------------+-------------------------------------------------+------+
| Name       | Fingerprint                                     | Type |
+------------+-------------------------------------------------+------+
| abmNodeKey | 25:fb:10:3c:ab:63:b1:3c:7d:df:35:78:46:f2:d7:f4 | ssh  |
+------------+-------------------------------------------------+------+
```

```sh
openstack flavor list
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
+-----+-----------+-------+------+-----------+-------+-----------+
| ID  | Name      |   RAM | Disk | Ephemeral | VCPUs | Is Public |
+-----+-----------+-------+------+-----------+-------+-----------+
| 0   | m1.tiny   |   512 |   10 |         0 |     1 | True      |
| 1   | m1.small  |  1024 |   20 |         0 |     1 | True      |
| 2   | m1.medium |  2048 |   40 |         0 |     2 | True      |
| 3   | m1.large  |  4096 |   80 |         0 |     2 | True      |
| 4   | m1.xlarge |  8192 |  160 |         0 |     4 | True      |
| 5   | m1.jumbo  | 16384 |  320 |         0 |     6 | True      |
+-----+-----------+-------+------+-----------+-------+-----------+
```

> **Note:** If you already have other resources in your **OpenStack**
> environment, those will also show up in the output above
---

### 3. Configure and execute Terraform

#### 3.1) Find the public `network id` in your OpenStack environment
```sh
# you can use this one line command if you have `jq` CLI tool installed
# if not use the "openstack network list --name=public" command to get the ID
export PUBLIC_NETWORK_ID=$(openstack network list --name=public -f json | jq -c '.[]."ID"' | tr -d '"')

# make sure you have the PUBLIC_NETWORK_ID environment variable is set
echo $PUBLIC_NETWORK_ID
```

#### 3.2) Generate the Terraform variables file
```sh
cat > terraform.tfvars << EOF
external_network_id = "$PUBLIC_NETWORK_ID"
os_user_name        = "$OS_USERNAME"
os_tenant_name      = "$OS_TENANT_NAME"
os_password         = "$OS_PASSWORD"
os_auth_url         = "$OS_AUTH_URL"
os_endpoint_type    = "$OS_ENDPOINT_TYPE"
ssh_key_name        = "$SSH_KEY_NAME"
EOF

# see it's contents
cat terraform.tfvars
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
external_network_id = "abce7af2-db6a-47db-b4dc-04598a73ec2d"
os_user_name        = "admin"
os_tenant_name      = ""
os_password         = "54e53c4ecc76fa84bec1374894583b8651332e0abe45c1de421ba797f669f35"
os_auth_url         = "https://10.128.0.2:5000"
os_endpoint_type    = ""
ssh_key_name        = "abmNodeKey"
```

#### 3.3) Initialize Terraform
```sh
# this sets up the required Terraform state management configurations, similar to 'git init'
terraform init
```

#### 3.4) Create a _Terraform execution_ plan
```sh
# compares the state of the resources, verifies the scripts and creates an execution plan
terraform plan
```

#### 3.5) Apply the changes described in the Terraform script
Review the **Terraform** script _([main.tf](/anthos-bm-openstack-terraform/main.tf))_
to see details of the configuration. Running this script will create the
required VMs and setup the networking inside **OpenStack** to install
**Anthos on bare metal**.

```sh
# executes the plan on the given provider (i.e: GCP) to reach the desired state of resources
terraform apply
```
```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

Outputs:

admin_ws_public_ip = "172.29.249.165"
```
> **Note 1:** When prompted to confirm the Terraform plan, type 'Yes' and enter
>
> **Note 2:** This step can take upto **90 seconds** to complete

```sh
# fetch the ip address using the Terraform output
export FLOATING_IP=$(terraform output admin_ws_public_ip | tr -d '"')
echo $FLOATING_IP
```

```sh
# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
172.29.249.165
```
---

### What Next?
You can now install **Anthos on bare metal** on the newly created OpenStack VMs
by [following this guide](install_abm.md).
