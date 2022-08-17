#!/bin/bash
# Copyright 2021 Google LLC
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

# shellcheck disable=SC1091

# [START anthosbaremetal_cloud_create_cloud_gce_baseline]

# Create n-number of GCE instances with named conventions to be picked up by Ansible

#### TODO: gcloud compute config-ssh  (on the host computer after GCEs are setup?)

## Get directory this script was run from. gce-helpers.vars is in the same directory.
## -- is used in case the directory name starts with a -
PREFIX_DIR=$(dirname -- "$0")
WORKDIR=$(pwd)
source ${PREFIX_DIR}/gce-helper.vars

# Defaults
GCE_COUNT=1
CLUSTER_START_INDEX=1
unset PREEMPTIBLE_OPTION
SSH_PUB_KEY_LOCATION="${WORKDIR}/build-artifacts/consumer-edge-machine.pub" # default


while getopts 'c:p:k:s:tz:': option
do
    # #*= allows for c=1 and strips out the c= in addition to -c 1
    case "${option}" in
        c) GCE_COUNT="${OPTARG#*=}";;
        k) SSH_PUB_KEY_LOCATION="${OPTARG#*=}";;
        p) PROJECT_ID="${OPTARG#*=}";;
        s) CLUSTER_START_INDEX="${OPTARG#*=}";;
        t) PREEMPTIBLE_OPTION="--preemptible";;
        z) ZONE="${OPTARG#*=}";;
    esac
done

usage()
{
    echo "Usage: $0
        [ -c NUM_INSTANCES ]
        [ -k SSH_PUB_KEY_LOCATION ]
        [ -p PROJECT_ID]
        [ -s STARTING_INDEX ]
        [ -t ]
        [ -z ZONE ]"
    echo "-c: Number of instances to create. Defaults to 1. Example: -c 1"
    echo "-k: SSH public key location. Defaults to './build-artifacts/consumer-edge-machine.pub'. Creates the key if it doesn't exist."
    echo "-p: project ID. Can be set with PROJECT_ID environment variable. Defaults to gcloud config if not set."
    echo "-s: Starting index. Defaults to 1. Example: -s 10."
    echo "-t: Use temporary preemptible instances."
    echo "-z: Zone. Can be set with ZONE environment variable. Defaults to gcloud config zone if not set."
    exit 2
}


###
###  Create and/or store public key used in ansible provisioning (ie, the "host" box)
###
function store_public_key_secret() {
    SSH_KEY_LOC=$1
    # Create SSH key if it doesn't exist
    create_ssh_key "${SSH_KEY_LOC}"

    create_secret "${SSH_KEY_SECRET_KEY}" "${SSH_KEY_LOC}" "true" # create the secret from a file
}

ERROR=0
if [[ ! -x $(command -v gcloud) ]]; then
    echo "Error: gcloud (Google Cloud SDK) command is required, but not installed."
    ERROR=1
fi

if [[ ! -x $(command -v envsubst) ]]; then
    echo "Error: envsubst (gettext) command is required, but not installed."
    ERROR=1
fi

if [[ ! -x $(command -v ssh-keygen) ]]; then
    echo "Error: ssh-keygen (SSH) command is required, but not installed."
    ERROR=1
fi

if [[ "${ERROR}" -eq 1 ]]; then
    exit 1
fi

ERROR=0
# Default to gcloud if not set
if [[ -z "${PROJECT_ID}" ]]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
fi

if [[ -z "${PROJECT_ID}" ]]; then
    echo "Error: No project ID set"
    ERROR=1
fi

# Default to gcloud if not set
if [[ -z "${ZONE}" ]]; then
    ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
fi

if [[ -z "${ZONE}" ]]; then
    echo "Error: No zone set"
    ERROR=1
fi

if [[ -z "${GCE_COUNT}" || ! "${GCE_COUNT}" =~ ^[0-9]+$ || "${GCE_COUNT}" -le 0 ]]; then
    echo "Error: Missing or invalid count variable"
    ERROR=1
fi

if [[ -z "${CLUSTER_START_INDEX}" || ! "${CLUSTER_START_INDEX}" =~ ^[0-9]+$ || "${CLUSTER_START_INDEX}" -le 0 ]]; then
    echo "Error: Missing or invalid starting index"
    ERROR=1
fi

if [[ "${ERROR}" -eq 1 ]]; then
    usage
    exit 1
fi

echo "GCE_COUNT: ${GCE_COUNT}"
echo "PROJECT_ID: ${PROJECT_ID}"
echo "START_INDEX: ${CLUSTER_START_INDEX}"
echo "ZONE: ${ZONE}"

if [[ ! -z "$PREEMPTIBLE_OPTION" ]]; then
    echo "NOTE: USING PREEMPTIBLE MACHINE. The GCE will be up at most 24h and will need to be re-created and re-provisioned. This option keeps the costs of testing/trying ABM Retail Edge to a minimum"
fi

# Check to make sure that the # of VMs is divisible by 3 (need 3 per location)
if [[ $((GCE_COUNT%REQUIRED_CLUSTER_SIZE)) != 0 ]]; then
    echo "The count ( $GCE_COUNT ) requested CNUCs needs to be multiples of 3"
    exit 1
fi

CLUSTER_COUNT=$(( GCE_COUNT/REQUIRED_CLUSTER_SIZE ))
echo "Final Cluster Count = $CLUSTER_COUNT"

###############################
#####   MAIN   ################
###############################

# enable any services needed
gcloud services enable \
    servicemanagement.googleapis.com \
    anthos.googleapis.com \
    cloudbuild.googleapis.com \
    cloudresourcemanager.googleapis.com \
    serviceusage.googleapis.com \
    compute.googleapis.com \
    secretmanager.googleapis.com

# Setup firewalls for GCE VXLAN (only needed by cloud-version) #TODO: Modify this to use tags on the GCE instances

# Look for any firewall rules with "vxlan" in them (see below for vxlan fireall entries...this works for both rules)
FIREWALLS=$(gcloud compute firewall-rules list --filter=name=vxlan --format="value(name)")
if [[ -z "${FIREWALLS}" ]]; then
    gcloud compute firewall-rules create vxlan-egress \
        --allow all \
        --direction=EGRESS \
        --network=${NETWORK} \
        --priority=900

    gcloud compute firewall-rules create vxlan-ingress \
        --allow all \
        --direction=INGRESS \
        --network=${NETWORK} \
        --priority=900 \
        --source-ranges="10.0.0.0/8"
fi

# setup default compute to view secrets and GCS buckets
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo "Adding roles/secretmanager.secretAccessor and roles/storage.objectViewer to default compute service account..."

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor" --no-user-output-enabled

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/storage.objectViewer" --no-user-output-enabled

# Create init script bucket for GCE instances to use
setup_init_bucket

# Create backup bucket for volume backups
setup_init_bucket ${BACKUP_BUCKET_NAME} ${PROJECT_ID}

# Copy the init script to bucket for GCE startup
copy_init_script

# Store the SSH pub key as a secret
store_public_key_secret "${SSH_PUB_KEY_LOCATION}"

# Create the GCE instances
create_gce_vms "$GCE_COUNT"

# Setup firewall rules to allow public pod access
setup_proxy_firewall

display_gce_vms_ips

# [END anthosbaremetal_cloud_create_cloud_gce_baseline]
