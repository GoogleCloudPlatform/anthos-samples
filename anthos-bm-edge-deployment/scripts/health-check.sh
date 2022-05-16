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

# [START anthosbaremetal_scripts_health_check]

case "$1" in

    "NUC" | "nuc" )
        GROUP="workers"
        ;;

    "cloud" | "CLOUD" | "cloud_type_abm" )
        GROUP="cloud_type_abm"
        ;;

    "all")
        GROUP="all"
        ;;

    *)
        GROUP="all"
        ;;
    esac

CWD=$(pwd)
INVENTORY_DIR="./inventory"

if [[ "${CWD}" == *"/scripts"* ]]; then
    INVENTORY_DIR="../inventory"
fi

echo $INVENTORY_DIR

ansible ${GROUP} -i ${INVENTORY_DIR} -m ansible.builtin.ping --one-line

# [END anthosbaremetal_scripts_health_check]
