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

# shellcheck disable=SC1091

# [START anthosbaremetal_scripts_status]

# Use the path to this script to determine the path to gce-helper.vars
PREFIX_DIR=$(dirname -- "$0")
# shellcheck source=./cloud/gce-helper.vars
source "${PREFIX_DIR}/cloud/gce-helper.vars"

display_gce_vms_ips

# [END anthosbaremetal_scripts_status]