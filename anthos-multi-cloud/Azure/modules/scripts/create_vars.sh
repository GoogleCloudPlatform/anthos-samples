#!/bin/bash

# create vars.sh file
set -e

  cat <<EOF > vars.sh
export CLUSTER_NAME=${1}
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export PROJECT_NUMBER=$(gcloud projects describe `gcloud info --format='value(config.project)'` --format='value(projectNumber)')
export GCP_LOCATION=${2}
export AZURE_REGION=${3}
export CLUSTER_VERSION=${4}
export SSH_PUBLIC_KEY=${5}
export SUBNET_ID=${6}

EOF