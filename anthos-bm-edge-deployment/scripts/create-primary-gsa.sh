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

echo "This will create a Google Service Account and key that is used on each of the Target machines to run gcloud commands"

GSA_NAME="target-machine-gsa"
GSA_EMAIL="${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
if [[ -z "${LOCAL_GSA_FILE}" ]]; then
  echo "Environment variable 'PROXY_PORT' is not set. Using default remote-gsa-key.json."
  KEY_LOCATION="./remote-gsa-key.json"
else
  KEY_LOCATION="${LOCAL_GSA_FILE}"
fi


EXISTS=$(gcloud iam service-accounts list --filter="email=${GSA_EMAIL}" --format="value(name, disabled)" --project="${PROJECT_ID}")
if [[ -z "${EXISTS}" ]]; then
    # GSA does NOT exist, create
    gcloud iam service-accounts create ${GSA_NAME} \
        --description="GSA used on each Target machine to make gcloud commands" \
        --display-name="target-machine-gsa" \
        --project "${PROJECT_ID}"
else
    if [[ "$EXISTS" =~ .*"disabled".* ]]; then
        # Found GSA is disabled, enable
        gcloud iam service-accounts enable "${GSA_EMAIL}" --project "${PROJECT_ID}"
    fi
    # otherwise, no need to do anything
fi

echo "Adding roles/editor"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="roles/editor" --no-user-output-enabled

echo "Adding roles/storage.objectViewer"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="roles/storage.objectViewer" --no-user-output-enabled

echo "Adding roles/resourcemanager.projectIamAdmin"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="roles/resourcemanager.projectIamAdmin" --no-user-output-enabled

echo "Adding roles/secretmanager.admin"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="roles/secretmanager.admin" --no-user-output-enabled

echo "Adding roles/secretmanager.secretAccessor"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="roles/secretmanager.secretAccessor" --no-user-output-enabled

echo "Adding roles/secretmanager.secretAccessor"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="roles/gkehub.gatewayAdmin" --no-user-output-enabled

echo "Adding roles/secretmanager.secretAccessor"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GSA_EMAIL}" \
    --role="roles/gkehub.viewer" --no-user-output-enabled

# We should have a GSA enabled or created or ready-to-go by here

echo -e "\n====================\n"

read -r -p "Create a new key for GSA? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    gcloud iam service-accounts keys create "${KEY_LOCATION}" \
        --iam-account="${GSA_EMAIL}" \
        --project "${PROJECT_ID}"
else
    echo "Skipping making new keys"
fi

# [END anthosbaremetal_scripts_create_primary_gsa]
