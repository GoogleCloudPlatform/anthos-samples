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

# [START anthos_scripts_create_vars]

# create vars.sh file
set -e

  cat <<EOF > vars.sh
export CLUSTER_NAME=${1}
export PROJECT_ID=$(gcloud info --format="value(config.project)")
export GCP_LOCATION=${2}
export AWS_REGION=${3}
export VPC_ID=${9}
export SUBNET_IDS=${8}
export CLUSTER_VERSION=${4}
export CONFIG_ENCRYPTION_KMS_KEY_ARN=${5}
export DATABASE_ENCRYPTION_KMS_KEY_ARN=${5}
export CP_IAM_ROLE_ARN=${7}
export CP_IAM_INSTANCE_PROFILE=${6}
export SERVICE_ADDRESS_CIDR_BLOCKS=${12}
export NODE_POOL_IAM_INSTANCE_PROFILE=${13}
export NODE_POOL_INSTANCE_TYPE=${14}
export NODE_POOL_CONFIG_ENCRYPTION_KEY=${15}
export NODE_POOL_ROOT_ENCRYPTION_KEY=${16}
#export NODE_POOL_SUBNET=
#pod_address_cidr_blocks="10.2.0.0/16"
#service_address_cidr_blocks="10.1.0.0/16"
#SSH_KEY_PAIR_NAME=

EOF

# [END anthos_scripts_create_vars]
