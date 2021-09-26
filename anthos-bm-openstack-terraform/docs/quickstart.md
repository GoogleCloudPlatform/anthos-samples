## Quick starter

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

#### 2.2) Create and upload SSH keys to be used by the OpenStack VMs
```sh
export SSH_KEY_NAME="abmNodeKey"
# generate the key pair
ssh-keygen -t -f ./${SSH_KEY_NAME}

# upload it to OpenStack
openstack keypair create $SSH_KEY_NAME --public-key ./${SSH_KEY_NAME}.pub
```

#### 2.3) Create OpenStack falvors that can be used to create VMs
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

openstack keypair list

# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
+------------+-------------------------------------------------+------+
| Name       | Fingerprint                                     | Type |
+------------+-------------------------------------------------+------+
| abmNodeKey | 25:fb:10:3c:ab:63:b1:3c:7d:df:35:78:46:f2:d7:f4 | ssh  |
+------------+-------------------------------------------------+------+

openstack flavor list

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
