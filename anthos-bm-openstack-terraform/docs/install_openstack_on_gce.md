## Deploying OpenStack Ussuri on Google Compute Engine VMs

This guide explains how to install an OpenStack _(Ussuri)_ environment on Google
Compute Engine (GCE) VMs using [nested virtualization](https://cloud.google.com/compute/docs/instances/nested-virtualization/overview).

The guide is split into 3 sections:
- Create a GCE instance with KVM enabled in Google Cloud Platform
- Install **OpenStack Ussuri** using the **[openstack-ansible in all-in-one](https://docs.openstack.org/openstack-ansible/latest/user/aio/quickstart.html)** mode
- Setup proper TLS certificates for accessing OpenStack your workstation
- Access and validate the deployed environment

Nested virtualization refers to the ability of running a virtual machine within
another, enabling this general concept extendable to an arbitrary depth.
Using nested KVM allows us to have minimal performance degradation when
OpenStack spins up user VMs in the GCE VM.

> **Note:** This is only for experimental purposes for trying OpenStack, **not**
> for running any actual workloads
---
### Pre-requisites
- A [Google Cloud Project](https://console.cloud.google.com/cloud-resource-manager) _(in which the resources for the setup will be provisioned)_
- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the
  following installed
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [OpenStack](https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html) (>= 5.5.x)


---

### 1. Create a GCE instance with KVM enabled in Google Cloud Platform

In this section we will create an `Ubuntu 20.04` _(Focal Fossa)_ image that has
a special license attached. Note that this is required; at this point in time
you can not enable nested KVM without this license being attached. So you have
to create a new GCE VM and can’t use nested KVM on an existing GCE instance.

1.1) Setup your environment
```sh
export PROJECT_ID="<YOUR_GCP_PROJECT_ID>"
export REGION="us-central1"   # this is an example; change to your preferred choice
export ZONE="us-central1-a"   # this is an example; change to your preferred choice

gcloud config set project "${PROJECT_ID}"
gcloud services enable compute.googleapis.com

gcloud config set compute/region "${REGION}"
gcloud config set compute/zone "${ZONE}"
```
> **Note:** This step can take upto 90 seconds to complete given the step for
> enabling the `Compute` APIs

1.2) Create a Compute Engine Disk
```sh
gcloud compute disks create ubuntu2004disk \
    --image-project ubuntu-os-cloud \
    --image-family ubuntu-2004-lts \
    --zone ${ZONE}
```

1.3) Create a `Ubuntu 20.04` image with the _required license for nested virtualization_
```sh
gcloud compute images create ubuntu-2004-nested \
    --source-disk ubuntu2004disk \
    --source-disk-zone ${ZONE} \
    --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
```

1.4) Create the GCE VM where we will install and run OpenStack
```sh
gcloud compute instances create openstack-1
    --zone ${ZONE} \
    --image ubuntu-2004-nested \
    --boot-disk-size 600G \
    --boot-disk-type pd-ssd \
    --can-ip-forward \
    --network default \
    --tags http-server,https-server,novnc,openstack-apis \
    --min-cpu-platform "Intel Haswell" \
    --machine-type n1-standard-32
```

1.5) Create Firewall rules to expose the Web UI and [noVNC](https://novnc.com/info.html)
```sh
gcloud compute firewall-rules create default-allow-novnc \
    --network default \
    --source-ranges 0.0.0.0/0 \
    --target-tags novnc \
    --direction ingress \
    --allow tcp:6080

gcloud compute firewall-rules create default-allow-openstack-apis \
    --network default \
    --source-ranges 0.0.0.0/0 \
    --target-tags openstack-apis \
    --direction ingress \
    --allow tcp:8773-8777

# The remaining 2 firewall rules are likely already created so don't worry if it
# fails with: "The resource 'bl/default-allow-http' already exists"
gcloud compute firewall-rules create default-allow-http \
    --network default \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --direction ingress \
    --allow tcp:80

gcloud compute firewall-rules create default-allow-https \
    --network default \
    --source-ranges 0.0.0.0/0 \
    --target-tags https-server \
    --direction ingress \
    --allow tcp:443
```

1.6) SSH into the VM and install KVM
```sh
# SSH into the GCE instance
gcloud compute ssh openstack-1 --zone ${ZONE}

# once inside the GCE instance, then install KVM as sudo
sudo -i
apt-get update && apt-get install qemu-kvm -y
```

1.7) Verify that KVM has been installed successfully
```sh
kvm-ok

# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
INFO: /dev/kvm exists
KVM acceleration can be used
```

> **Note:** In case you hit any issues, please take a look at the [Nested KVM
> docs for GCP](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances).
---
### 2. Install _OpenStack Ussuri_ using the _openstack-ansible in all-in-one_ mode

2.1) Clone the **OpenStack** repository into the GCE instance
```sh
### NOTE: YOU MUST BE SSH'ed INTO THE 'openstack-1' GCE VM we created earlier

# start a screen session because some commands are going to take a while you
# can always re-attach later with "screen -r -D" if you lose your SSH session
screen

git clone https://opendev.org/openstack/openstack-ansible /opt/openstack-ansible
cd /opt/openstack-ansible
git checkout stable/ussuri
```

2.2) Install [Ansible](https://www.ansible.com/) and all the required Ansible
roles on the GCE instance
```sh
scripts/bootstrap-ansible.sh

# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
```
> **Note:** _This step can take upto ***X seconds*** to complete_

2.3) Setup the environment on the GCE instance for **OpenStack** installation
```sh
export SCENARIO='aio_lxc_barbican_octavia'
# run the following script again if you hit any issues
scripts/bootstrap-aio.sh

# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
```

2.4) Make a change to the Ansible playbook configs to overcome a [known issue](https://bugs.launchpad.net/openstack-ansible/+bug/1903344)
```sh
vi /etc/ansible/roles/openstack_hosts/defaults/main.yml

# Inside vi editor:
#   - Go to line 109 by typing :109 then [return] key
#   - The line should have "109:  - { key: 'net.bridge.bridge-nf-call-iptables', value: 1 }"
#   - Go to the end of the line and delete "1" by pressing [x] whilst the cursor is on it
#   - Then, press [i] to get into insert mode and add "0" to where there was "1" before
#   - Exit vi (ノಠ益ಠ)ノ彡┻━┻ by pressing: [Esc] then [:wq] and [return] key
#   - Line 109 should look like this after the change:
#       109:  - { key: 'net.bridge.bridge-nf-call-iptables', value: 0 }
```

2.5) Run the ansible-playbooks to install **OpenStack Ussuri** on the GCE instance
```sh
openstack-ansible \
    playbooks/setup-hosts.yml \
    playbooks/setup-infrastructure.yml \
    playbooks/setup-openstack.yml

# -----------------------------------------------------
#                   Expected Output
# -----------------------------------------------------
```
> **Note 1:** _This step can take upto ***X minutes*** to complete_
>
> **Note 2:** Sometimes you might hit an issue where the **setup-hosts.yml** playbook hangs with `RETRYING: Ensure that the LXC cache has been prepared (14 retries left)`. The root cause is that downloading the packages sometimes gets stuck, so just rerun the playbook **openstack-ansible playbooks/setup-hosts.yml**. You can read more about using openstack-ansible [here](https://docs.openstack.org/openstack-ansible/stein/user/aio/quickstart.html)
---

### 3. Setup proper TLS certificates for accessing OpenStack your workstation

3.1) Download the utility script to create a self-signed certificate with IP SAN
```sh
curl -O https://gist.githubusercontent.com/sethvargo/81227d2316207b7bd110df328d83fad8/raw/836c5c2650584d3279cb386f17b2a00aa91008fd/create-certs.sh
```

3.2) Edit the script to match your IP addresses and hostnames
```sh
```
