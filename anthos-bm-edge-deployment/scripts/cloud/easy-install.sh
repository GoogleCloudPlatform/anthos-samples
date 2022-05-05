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

# [START anthosbaremetal_cloud_easy_install]

ROOT_DIR=$(pwd)

echo "💡 -------------------------------------------------------------------"
echo "💡 Creating SSH keys to be used for logging into GCE instances..."
echo "💡 -------------------------------------------------------------------"
ssh-keygen -t ed25519 -f ~/.ssh/cnucs-cloud

echo "
### Host configuration for Anthos BareMetal cnucs
Host cnuc-*
    User abm-admin
    StrictHostKeyChecking no
    IdentitiesOnly=yes
    IdentityFile ~/.ssh/cnucs-cloud" >> ~/.ssh/config

echo "💡 -------------------------------------------------------------------"
echo "💡 Creating GCE instances where Anthos Bare Metal will be installed..."
echo "💡 -------------------------------------------------------------------"
${ROOT_DIR}/scripts/cloud/create-cloud-gce-baseline.sh -c ${MACHINE_COUNT}

echo "💡 -------------------------------------------------------------------"
echo "💡 Updating /etc/hosts with the IP addresses of the GCE instances..."
echo "💡 -------------------------------------------------------------------"
${ROOT_DIR}/scripts/status.sh | tail -$((${MACHINE_COUNT}+1)) > temp.log
sudo sh -c 'cat temp.log >> /etc/hosts'
rm -rf temp.log

echo "✅ GCE Instances setup completed!"

# [END anthosbaremetal_cloud_easy_install]