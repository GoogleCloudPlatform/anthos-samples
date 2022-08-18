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


## This script is used to setup the docker image for Consumer Edge installation and ensure
##     This script is referenced by `crontab` running every minute

if ! grep -q "AUTO-GENERATED-CONSUMER-EDGE" "/etc/hosts"; then
    # Only apply IF the file does not contain AUTO-GENERATED
    /var/consumer-edge-install/scripts/gce-status.sh true >> /etc/hosts

    # If the file "add-hosts" exists, add these to the bottom of the /etc/hosts file (usually used for physical machines)
    if [ -f "/var/consumer-edge-install/build-artifacts/add-hosts" ]; then
        echo "" >> /etc/hosts
        cat /var/consumer-edge-install/build-artifacts/add-hosts >> /etc/hosts
    fi
fi