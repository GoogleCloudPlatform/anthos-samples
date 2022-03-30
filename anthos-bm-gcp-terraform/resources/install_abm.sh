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

# [START anthosbaremetal_resources_install_abm]

DIR=$(pwd)
CLUSTER_ID=$(cut -d "=" -f2- <<< "$(grep < init.vars CLUSTER_ID)")

# run the initialization checks
"$DIR"/run_initialization_checks.sh
# create a new workspace and config file for the Anthos bare metal cluster
bmctl create config -c "$CLUSTER_ID"
# copy the prefilled configuration file into the new workspace
cp "$DIR/$CLUSTER_ID".yaml "$DIR/bmctl-workspace/$CLUSTER_ID"
# create the Anthos bare metal cluster
bmctl create cluster -c "$CLUSTER_ID"

echo "Anthos on bare metal installation complete!"
echo "Run [export KUBECONFIG=$DIR/bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID-kubeconfig] to set the kubeconfig"
echo "Run the [$DIR/login.sh] script to generate a token that you can use to login to the cluster from the Google Cloud Console"

# [END anthosbaremetal_resources_install_abm]
