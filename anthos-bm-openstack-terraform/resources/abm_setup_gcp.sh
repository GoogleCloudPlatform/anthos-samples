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

# [START anthosbaremetal_resources_abm_setup_gcp]

##############################################################################
# Download the service account key in order to configure the Anthos cluster
##############################################################################
function __setup_service_account__ () {
  gcloud iam service-accounts create "${SERVICE_ACCOUNT}"
  if ! gcloud iam service-accounts keys create bm-gcr.json --iam-account="${SERVICE_ACCOUNT}"@"${PROJECT_ID}".iam.gserviceaccount.com
  then
    echo "[+] Successfully downloaded key for service account [$SERVICE_ACCOUNT]"
  else
    echo "[-] Failed to download key for service account [$SERVICE_ACCOUNT]." >&2
    exit "$?"
  fi
}

cat << EOM
------------------------------------------------------------------------------
|    Enabling the following Google Cloud services in project ${PROJECT_ID}   |
------------------------------------------------------------------------------
  - anthos.googleapis.com
  - anthosgke.googleapis.com
  - cloudresourcemanager.googleapis.com
  - container.googleapis.com
  - gkeconnect.googleapis.com
  - gkehub.googleapis.com
  - serviceusage.googleapis.com
  - stackdriver.googleapis.com
  - monitoring.googleapis.com
  - logging.googleapis.com
  - opsconfigmonitoring.googleapis.com
  - anthosaudit.googleapis.com
------------------------------------------------------------------------------
EOM
gcloud services enable \
    anthos.googleapis.com \
    anthosgke.googleapis.com \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    serviceusage.googleapis.com \
    stackdriver.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    opsconfigmonitoring.googleapis.com \
    anthosaudit.googleapis.com


echo "Setting up Service Account ${SERVICE_ACCOUNT}"
__setup_service_account__

cat << EOM
------------------------------------------------------------------------------
|  Adding the following IAM roles to the service account ${SERVICE_ACCOUNT}  |
------------------------------------------------------------------------------
  - roles/gkehub.connect
  - roles/gkehub.admin
  - roles/logging.logWriter
  - roles/monitoring.metricWriter
  - roles/monitoring.dashboardEditor
  - roles/stackdriver.resourceMetadata.writer
  - roles/opsconfigmonitoring.resourceMetadata.writer
------------------------------------------------------------------------------
EOM
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.connect"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.admin"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.dashboardEditor"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/stackdriver.resourceMetadata.writer"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/opsconfigmonitoring.resourceMetadata.writer"

# [END anthosbaremetal_resources_abm_setup_gcp]
