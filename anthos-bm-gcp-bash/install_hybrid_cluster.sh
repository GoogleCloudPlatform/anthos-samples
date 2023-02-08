#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

if [[ -z "${PROJECT_ID}" ]]; then
  printf "🚨 Environment variable PROJECT_ID is not set. Set it to the Google Cloud Project you intend to use."
  exit 1
fi

if [[ -z "${ZONE}" ]]; then
  printf "🚨 Environment variable ZONE is not set. Set it to the Google Cloud Zone where the resources must be created."
  exit 1
fi

if [[ -z "${CLUSTER_NAME}" ]]; then
  printf "🚨 Environment variable CLUSTER_NAME is not set.\n"
  while true; do
    read -rp "💡 Should the script continue with the default name - 'abm-cluster'? " yn
    case $yn in
        [Yy]* ) CLUSTER_NAME="abm-cluster"; break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
fi

if [[ -z "${BMCTL_VERSION}" ]]; then
  printf "🚨 Environment variable BMCTL_VERSION not set. Set it to the Anthos bare metal version you intend to use."
  exit 1
fi

printf "\n✅ Using Project [%s], Zone [%s], Cluster name [%s] and Anthos bare metal version [%s].\n\n" "$PROJECT_ID" "$ZONE" "$CLUSTER_NAME" "$BMCTL_VERSION"

# create the GCP Service Account to be used by Anthos on bare metal
printf "🔄 Creating Service Account and Service Account key...\n"
# [START anthos_bm_gcp_bash_hybrid_create_sa]
gcloud iam service-accounts create baremetal-gcr

gcloud iam service-accounts keys create bm-gcr.json \
    --iam-account=baremetal-gcr@"${PROJECT_ID}".iam.gserviceaccount.com
# [END anthos_bm_gcp_bash_hybrid_create_sa]
printf "✅ Successfully created Service Account and downloaded key file.\n\n"

# enable all the required APIs for Anthos on bare metal
printf "🔄 Enabling GCP Service APIs...\n"
# [START anthos_bm_gcp_bash_hybrid_enable_api]
gcloud services enable \
    anthos.googleapis.com \
    anthosaudit.googleapis.com \
    anthosgke.googleapis.com \
    cloudresourcemanager.googleapis.com \
    connectgateway.googleapis.com \
    container.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    serviceusage.googleapis.com \
    stackdriver.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    opsconfigmonitoring.googleapis.com
# [END anthos_bm_gcp_bash_hybrid_enable_api]
printf "✅ Successfully enabled GCP Service APIs.\n\n"

# add all the required IAM roles to the Service Account
printf "🔄 Adding IAM roles to the Service Account...\n"
# [START anthos_bm_gcp_bash_hybrid_add_iam_role]
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.connect" \
  --no-user-output-enabled

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.admin" \
  --no-user-output-enabled

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter" \
  --no-user-output-enabled

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter" \
  --no-user-output-enabled

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.dashboardEditor" \
  --no-user-output-enabled

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/stackdriver.resourceMetadata.writer" \
  --no-user-output-enabled

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/opsconfigmonitoring.resourceMetadata.writer" \
  --no-user-output-enabled
# [END anthos_bm_gcp_bash_hybrid_add_iam_role]
printf "✅ Successfully added the requires IAM roles to the Service Account.\n\n"

# declare arrays for VM names and IPs
printf "🔄 Setting up array variables for the VM names and IP addresses...\n"
# [START anthos_bm_gcp_bash_hybrid_vms_array]
MACHINE_TYPE=n1-standard-8
VM_PREFIX=abm
VM_WS=$VM_PREFIX-ws
VM_CP1=$VM_PREFIX-cp1
VM_CP2=$VM_PREFIX-cp2
VM_CP3=$VM_PREFIX-cp3
VM_W1=$VM_PREFIX-w1
VM_W2=$VM_PREFIX-w2
declare -a VMs=("$VM_WS" "$VM_CP1" "$VM_CP2" "$VM_CP3" "$VM_W1" "$VM_W2")
declare -a IPs=()
# [END anthos_bm_gcp_bash_hybrid_vms_array]
printf "✅ Variables for the VM names and IP addresses setup.\n\n"

# create GCE VMs
printf "🔄 Creating GCE VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_create_vm]
for vm in "${VMs[@]}"
do
    gcloud compute instances create "$vm" \
      --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
      --zone="${ZONE}" \
      --boot-disk-size 200G \
      --boot-disk-type pd-ssd \
      --can-ip-forward \
      --network default \
      --tags http-server,https-server \
      --min-cpu-platform "Intel Haswell" \
      --enable-nested-virtualization \
      --scopes cloud-platform \
      --machine-type "$MACHINE_TYPE" \
      --metadata "cluster_id=${CLUSTER_NAME},bmctl_version=${BMCTL_VERSION}"
    IP=$(gcloud compute instances describe "$vm" --zone "${ZONE}" \
         --format='get(networkInterfaces[0].networkIP)')
    IPs+=("$IP")
done
# [END anthos_bm_gcp_bash_hybrid_create_vm]
printf "✅ Successfully created GCE VMs.\n\n"

# verify SSH access to the Google Compute Engine VMs
printf "🔄 Checking SSH access to the GCE VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_check_ssh]
for vm in "${VMs[@]}"
do
    while ! gcloud compute ssh root@"$vm" --zone "${ZONE}" --command "printf SSH to $vm succeeded"
    do
        printf "Trying to SSH into %s failed. Sleeping for 5 seconds. zzzZZzzZZ" "$vm"
        sleep  5
    done
done
# [END anthos_bm_gcp_bash_hybrid_check_ssh]
printf "✅ Successfully connected to all the GCE VMs using SSH.\n\n"

# setup VxLAN configurations in all the VMs to enable L2-network connectivity
# between them
printf "🔄 Setting up VxLAN in the GCE VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_add_vxlan]
i=2 # We start from 10.200.0.2/24
for vm in "${VMs[@]}"
do
    gcloud compute ssh root@"$vm" --zone "${ZONE}" << EOF
        apt-get -qq update > /dev/null
        apt-get -qq install -y jq > /dev/null
        set -x
        ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
        current_ip=\$(ip --json a show dev ens4 | jq '.[0].addr_info[0].local' -r)
        printf "VM IP address is: \$current_ip"
        for ip in ${IPs[@]}; do
            if [ "\$ip" != "\$current_ip" ]; then
                bridge fdb append to 00:00:00:00:00:00 dst \$ip dev vxlan0
            fi
        done
        ip addr add 10.200.0.$i/24 dev vxlan0
        ip link set up dev vxlan0

EOF
    i=$((i+1))
done
# [END anthos_bm_gcp_bash_hybrid_add_vxlan]
printf "✅ Successfully setup VxLAN in the GCE VMs.\n\n"

# install the necessary tools inside the VMs
printf "🔄 Setting up admin workstation...\n"
# [START anthos_bm_gcp_bash_hybrid_init_vm]
gcloud compute ssh root@$VM_WS --zone "${ZONE}" << EOF
set -x

export PROJECT_ID=\$(gcloud config get-value project)
BMCTL_VERSION=\$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/bmctl_version -H "Metadata-Flavor: Google")
export BMCTL_VERSION

gcloud iam service-accounts keys create bm-gcr.json \
  --iam-account=baremetal-gcr@\${PROJECT_ID}.iam.gserviceaccount.com

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
mv kubectl /usr/local/sbin/
mkdir baremetal && cd baremetal
gsutil cp gs://anthos-baremetal-release/bmctl/$BMCTL_VERSION/linux-amd64/bmctl .
chmod a+x bmctl
mv bmctl /usr/local/sbin/

cd ~
printf "Installing docker"
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
EOF
# [END anthos_bm_gcp_bash_hybrid_init_vm]
printf "✅ Successfully set up admin workstation.\n\n"

# generate SSH key-pair in the admin workstation VM and copy the public-key
# to all the other (control-plane and worker) VMs
printf "🔄 Setting up SSH access from admin workstation to cluster node VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_add_ssh_keys]
gcloud compute ssh root@$VM_WS --zone "${ZONE}" << EOF
set -x
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
sed 's/ssh-rsa/root:ssh-rsa/' ~/.ssh/id_rsa.pub > ssh-metadata
for vm in ${VMs[@]}
do
    gcloud compute instances add-metadata \$vm --zone ${ZONE} --metadata-from-file ssh-keys=ssh-metadata
done
EOF
# [END anthos_bm_gcp_bash_hybrid_add_ssh_keys]
printf "✅ Successfully set up SSH access from admin workstation to cluster node VMs.\n\n"

# initiate Anthos on bare metal installation from the admin workstation
printf "🔄 Installing Anthos on bare metal...\n"
# [START anthos_bm_gcp_bash_hybrid_install_abm]
gcloud compute ssh root@$VM_WS --zone "${ZONE}" <<EOF
set -x
export PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME=\$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/cluster_id -H "Metadata-Flavor: Google")
BMCTL_VERSION=\$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/bmctl_version -H "Metadata-Flavor: Google")
export CLUSTER_NAME
export BMCTL_VERSION
bmctl create config -c \$CLUSTER_NAME
cat > bmctl-workspace/\$CLUSTER_NAME/\$CLUSTER_NAME.yaml << EOB
---
gcrKeyPath: /root/bm-gcr.json
sshPrivateKeyPath: /root/.ssh/id_rsa
gkeConnectAgentServiceAccountKeyPath: /root/bm-gcr.json
gkeConnectRegisterServiceAccountKeyPath: /root/bm-gcr.json
cloudOperationsServiceAccountKeyPath: /root/bm-gcr.json
---
apiVersion: v1
kind: Namespace
metadata:
  name: cluster-\$CLUSTER_NAME
---
apiVersion: baremetal.cluster.gke.io/v1
kind: Cluster
metadata:
  name: \$CLUSTER_NAME
  namespace: cluster-\$CLUSTER_NAME
spec:
  type: hybrid
  anthosBareMetalVersion: \$BMCTL_VERSION
  gkeConnect:
    projectID: \$PROJECT_ID
  controlPlane:
    nodePoolSpec:
      clusterName: \$CLUSTER_NAME
      nodes:
      - address: 10.200.0.3
      - address: 10.200.0.4
      - address: 10.200.0.5
  clusterNetwork:
    pods:
      cidrBlocks:
      - 192.168.0.0/16
    services:
      cidrBlocks:
      - 172.26.232.0/24
  loadBalancer:
    mode: bundled
    ports:
      controlPlaneLBPort: 443
    vips:
      controlPlaneVIP: 10.200.0.49
      ingressVIP: 10.200.0.50
    addressPools:
    - name: pool1
      addresses:
      - 10.200.0.50-10.200.0.70
  clusterOperations:
    # might need to be this location
    location: us-central1
    projectID: \$PROJECT_ID
  storage:
    lvpNodeMounts:
      path: /mnt/localpv-disk
      storageClassName: node-disk
    lvpShare:
      numPVUnderSharedPath: 5
      path: /mnt/localpv-share
      storageClassName: local-shared
  nodeConfig:
    podDensity:
      maxPodsPerNode: 250
---
apiVersion: baremetal.cluster.gke.io/v1
kind: NodePool
metadata:
  name: node-pool-1
  namespace: cluster-\$CLUSTER_NAME
spec:
  clusterName: \$CLUSTER_NAME
  nodes:
  - address: 10.200.0.6
  - address: 10.200.0.7
EOB

bmctl create cluster -c \$CLUSTER_NAME
EOF
# [END anthos_bm_gcp_bash_hybrid_install_abm]
printf "✅ Installation complete. Please check the logs for any errors!!!\n\n"
