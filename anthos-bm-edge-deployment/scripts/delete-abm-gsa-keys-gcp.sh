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

# [START anthosbaremetal_scripts_delete_abm_gsa_keys_gcp]

# Remove all service account keys for the ABM GSAs from GCP

GSAs=(
    "abm-gke-register-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "abm-cloud-operations-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "abm-gcr-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "abm-gke-connect-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "external-secrets-k8s@${PROJECT_ID}.iam.gserviceaccount.com"
     )

# gcloud iam service-accounts keys create /var/keys/abm-gke-register-agent-creds.json --iam-account=abm-gke-register-agent@anthos-bare-metal-lab-1.iam.gserviceaccount.com --project=anthos-bare-metal-lab-1

for GSA in "${GSAs[@]}"
do
    KEYS=$(gcloud iam service-accounts keys list --iam-account="$GSA" --format="value(name)" --managed-by="user" --project="${PROJECT_ID}")
    echo "Removing ${#KEYS[@]} keys for: $GSA"
    for KEY in "${KEYS[@]}"
    do
        gcloud iam service-accounts keys delete "$KEY" --iam-account="$GSA" --quiet --project="${PROJECT_ID}"
    done
done
# [END anthosbaremetal_scripts_delete_abm_gsa_keys_gcp]