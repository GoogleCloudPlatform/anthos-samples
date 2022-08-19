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


# GSA Key used for provisioning (result of running ./scripts/create-primary-gsa.sh)
LOCAL_GSA_FILE=$(pwd)/build-artifacts/consumer-edge-gsa.json
export LOCAL_GSA_FILE
# GCP Project ID
export PROJECT_ID="$PROJECT_ID"
# Bucket to store cluster snapshot information
export SNAPSHOT_GCS="$PROJECT_ID-cluster-snapshots"

# GCP Project Region (Adjust as desired)
export REGION="$REGION"
# GCP Project Zone (Adjust as desired)
export ZONE="$ZONE"

# (Optional, typically workshop only) Assigned name/number. This is the ACM Cluster object's name (needs to be unique across fleet)
# export CLUSTER_ACM_NAME="location-1"

# Gitlab Personal Access Token credentials (generated in Quick Start step 2)
export SCM_TOKEN_USER="$SCM_TOKEN_USER"
export SCM_TOKEN_TOKEN="$SCM_TOKEN_TOKEN"

# Default Root Repo setup for multiple locations
export ROOT_REPO_URL="$ROOT_REPO_URL"
export ROOT_REPO_BRANCH="main"
export ROOT_REPO_DIR="/anthos-bm-edge-deployment/acm-config-sink"

# OIDC Configuration (off by default)
export OIDC_CLIENT_ID="" # Optional, requires GCP API setup work
export OIDC_CLIENT_SECRET="" # Optional
export OIDC_USER="" # Optional
export OIDC_ENABLED="false" # Flip to true IF implementing OIDC on cluster
