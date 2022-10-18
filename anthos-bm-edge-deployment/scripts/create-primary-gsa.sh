#!/bin/bash -e
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

# [START anthosbaremetal_scripts_create_primary_gsa]
# [START_EXCLUDE]
set -e

echo "This will create a Google Service Account and key that is used on each of the target machines to run gcloud commands"

PROJECT_ID=${1:-${PROJECT_ID}}
GSA_NAME="target-machine-gsa"
GSA_EMAIL="${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KEY_LOCATION="./build-artifacts/consumer-edge-gsa.json"

KMS_KEY_NAME="gdc-ssh-key"
KMS_KEYRING_NAME="gdc-ce-keyring"
KMS_KEYRING_LOCATION=${2-"global"}

if [[ -z "${PROJECT_ID}" ]]; then
  echo "Project ID required, provide as script argument or 'export PROJECT_ID={}'"
  exit 1
fi
# [END_EXCLUDE]
EXISTS=$(gcloud iam service-accounts list \
  --filter="email=${GSA_EMAIL}" \
  --format="value(name, disabled)" \
  --project="${PROJECT_ID}")

if [[ -z "${EXISTS}" ]]; then
  echo "GSA [${GSA_EMAIL}]does not exist, creating it"

  # GSA does NOT exist, create
  gcloud iam service-accounts create ${GSA_NAME} \
    --description="GSA used on each Target machine to make gcloud commands" \
    --display-name="target-machine-gsa" \
    --project "${PROJECT_ID}"
else
  if [[ "${EXISTS}" =~ .*"disabled".* ]]; then
    # Found GSA is disabled, enable
    gcloud iam service-accounts enable "${GSA_EMAIL}" --project "${PROJECT_ID}"
  fi
  # otherwise, no need to do anything
fi
# [START_EXCLUDE]
# FIXME: These are not specific to GSA creation, but necessary for project
# setup (future, this will all be terraform)
gcloud services enable --project "${PROJECT_ID}" \
  cloudkms.googleapis.com \
  compute.googleapis.com \
  containerregistry.googleapis.com \
  secretmanager.googleapis.com \
  servicemanagement.googleapis.com \
  serviceusage.googleapis.com \
  sourcerepo.googleapis.com

### Create Keyring for SSH key encryption (future terraform) -- Keyring and
# keys are used to encrypt/decrypt SSH keys on the provisioning system during
# provisioning (target host has the pub-key matching encrypted private key)
HAS_KEYRING=$(gcloud kms keyrings list \
  --location="${KMS_KEYRING_LOCATION}" \
  --format="value(name)" \
  --filter="name~${KMS_KEYRING_NAME}" \
  --project "${PROJECT_ID}")

if [[ -z "${HAS_KEYRING}" ]]; then
  gcloud kms keyrings create "${KMS_KEYRING_NAME}" \
    --location="${KMS_KEYRING_LOCATION}" \
    --project "${PROJECT_ID}"
fi

### Check to see if key exists, create if not
HAS_KEY=$(gcloud kms keys list \
  --location="${KMS_KEYRING_LOCATION}" \
  --keyring="${KMS_KEYRING_NAME}" \
  --format="value(name)" \
  --project "${PROJECT_ID}")

if [[ -z "${HAS_KEY}" ]]; then
  gcloud kms keys create "${KMS_KEY_NAME}" \
    --keyring "${KMS_KEYRING_NAME}" \
    --location "${KMS_KEYRING_LOCATION}" \
    --purpose "encryption" \
    --project "${PROJECT_ID}"
fi

### Set roles for GSA
declare -a ROLES=(
  "roles/editor"
  "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  "roles/gkehub.gatewayAdmin"
  "roles/gkehub.viewer"
  "roles/resourcemanager.projectIamAdmin"
  "roles/secretmanager.admin"
  "roles/secretmanager.secretAccessor"
  "roles/storage.objectViewer"
)

for role in "${ROLES[@]}"; do
  echo "Adding ${role}"
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="${role}" \
    --no-user-output-enabled
done

# We should have a GSA enabled or created or ready-to-go by here

echo -e "\n====================\n"

read -r -p "Create a new key for GSA? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  gcloud iam service-accounts keys create ${KEY_LOCATION} \
    --iam-account="${GSA_EMAIL}" \
    --project "${PROJECT_ID}"

  # reducing OS visibility to read-only for current user
  chmod 400 ${KEY_LOCATION}
else
  echo "Skipping making new keys"
fi
# [END_EXCLUDE]
# [END anthosbaremetal_scripts_create_primary_gsa]
