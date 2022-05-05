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

# [START anthosbaremetal_cloud_delete_cloud_gce_baseline]

echo "Looking for instances..."

INSTANCES=()
# By default, remove all GCE instances
if [[ -n "$1" ]]; then
    instance_name="cnuc-$1"
    INSTANCE=$(gcloud compute instances list --filter="name=$instance_name" --format="value(name, zone)" 2>/dev/null ) # error goes to /dev/null
    if [[ -z "${INSTANCE}" ]]; then
        echo "${instance_name} does not exist in this project. Skipping..."
        exit 1
    fi
    INSTANCES+=("$INSTANCE")
else
    # get list of all CNUCs in the project
    LABELS="labels.type=abm"
    IFS=$'\r\n'
    while IFS=$'\r\n' read -r line;
    do
        INSTANCES+=("$line");
    done < <(gcloud compute instances list --filter="${LABELS}" --format="value(name, zone)" 2>/dev/null)
fi

echo -e "\nRemoving '${#INSTANCES[@]}' instances"

if [[ ${#INSTANCES[@]} -lt 1 ]]; then
    echo -e "\nNo instances found...\n"
    exit 0
fi

for instance in "${INSTANCES[@]}"
do
    # Convert to string array
    IFS=$' \t'
    inst=("$instance")
    instance_name="${inst[0]}"
    instance_zone="${inst[1]}"
    echo -e "\nRemoving ${instance_name} in ${instance_zone}..."
    echo -e "  -- Removing GKE Hub Assignment"
    gcloud container hub memberships delete "${instance_name}" --quiet --async 2> /dev/null
    echo -e "  -- Deleting instance"
    gcloud compute instances delete "${instance_name}" --zone "${instance_zone}" -q
    echo -e "  -- Done!\n"
done

# [END anthosbaremetal_cloud_delete_cloud_gce_baseline]