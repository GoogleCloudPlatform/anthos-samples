
# GSA Key used for provisioning (result of running ./scripts/create-primary-gsa.sh)
export LOCAL_GSA_FILE=$(pwd)/build-artifacts/consumer-edge-gsa.json
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