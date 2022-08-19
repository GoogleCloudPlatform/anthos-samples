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


##
## This script is used to obtain the IP addresses of GCE instances. The output has two formats, the full which adds helpful SSH commands (remove existing fingerprints) along with output intended for /etc/hosts with the relevant SSH information to GCE instances, the the second is just the /etc/hosts output
##
## ./scripts.sh  <---- this is the full run
##
## ./scripts.sh true <--- This is ONLY the /etc/hosts formatted output intended for cut-copy-paste into /etc/hosts (used in the Docker container build)
##
## NOTE: There is a dependency of this script in the Docker image used in provisioning machines
##

# Use the path to this script to determine the path to gce-helper.vars
PREFIX_DIR=$(dirname -- "$0")
# shellcheck disable=SC1090,SC1091
source "${PREFIX_DIR}/cloud/gce-helper.vars"

if [[ ! -f "./build-artifacts/consumer-edge-machine.pub" ]]; then
    echo "ERROR: SSH key used to communicate with remote machines does not exist. Please setup key and place the public key here: './build-artifacts/consumer-edge-machine.pub'"
    exit 1
fi

SSH_KEY="./build-artifacts/consumer-edge-machine.pub"

if [[ -n $1 ]]; then
    # any parameter passed will trigger ONLY the /etc/hosts format for cnucs
    display_ip_host_format
else
    display_gce_vms_ips "${SSH_KEY}"
fi
