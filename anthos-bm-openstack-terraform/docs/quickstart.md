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

# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
+------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field            | Value                                                                                                                                                           |
+------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+
| container_format | bare                                                                                                                                                            |
| created_at       | 2021-09-26T00:04:18Z                                                                                                                                            |
| disk_format      | qcow2                                                                                                                                                           |
| id               | 4188935a-9025-4f80-b1f5-8012bc553b20                                                                                                                            |
| ...                                                                                                                                                                                |
| name             | ubuntu-2004                                                                                                                                                     |
| ...                                                                                                                                                                                |
| visibility       | public                                                                                                                                                          |
+------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+

```
