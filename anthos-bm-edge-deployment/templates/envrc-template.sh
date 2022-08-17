
# GSA Key used for provisioning (result of running ./scripts/create-primary-gsa.sh)
export LOCAL_GSA_FILE=$(pwd)/build-artifacts/consumer-edge-gsa.json
# GCP Project ID
export PROJECT_ID="###__GCP_PROJECT_ID__###"
# Bucket to store cluster snapshot information
export SNAPSHOT_GCS="###__GCP_PROJECT_ID__###-cluster-snapshots"

# GCP Project Region (Adjust as desired)
export REGION="us-west1"
# GCP Project Zone (Adjust as desired)
export ZONE="us-west1-b"

# (Optional, typically workshop only) Assigned name/number. This is the ACM Cluster object's name (needs to be unique across fleet)
# export CLUSTER_ACM_NAME="location-1"

# Gitlab Personal Access Token credentials (generated in Quick Start step 2)
export SCM_TOKEN_USER="###_Repo_Login_Name_###"
export SCM_TOKEN_TOKEN="###_Repo_PAT_Token_###"

# Default Root Repo setup for multiple locations
export ROOT_REPO_URL="https://gitlab.com/gcp-solutions-public/retail-edge/root-repo-public-template.git"
export ROOT_REPO_BRANCH="main"
export ROOT_REPO_DIR="/config"

# OIDC Configuration (off by default)
export OIDC_CLIENT_ID="" # Optional, requires GCP API setup work
export OIDC_CLIENT_SECRET="" # Optional
export OIDC_USER="" # Optional
export OIDC_ENABLED="false" # Flip to true IF implementing OIDC on cluster