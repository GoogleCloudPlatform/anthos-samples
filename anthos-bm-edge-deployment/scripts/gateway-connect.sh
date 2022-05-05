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

# [START anthosbaremetal_scripts_gateway_connect]

CLUSTER_NAME=$1

UNSET=$1

if [[ -z "${CLUSTER_NAME}" ]]; then

    echo "Please supply a gke-hub cluster name"
    echo -e "\ngateway-connect.sh <clusterName> <optional true>\n"
    exit 1
fi

COMMAND="set"

if [[ -n "${UNSET}" ]]; then
    COMMAND="unset"
fi

gcloud config "${COMMAND}" auth/impersonate_service_account "gateway-connect-agent@${PROJECT_ID}.iam.gserviceaccount.com"
gcloud beta container hub memberships get-credentials "$CLUSTER_NAME"

# [END anthosbaremetal_scripts_gateway_connect]