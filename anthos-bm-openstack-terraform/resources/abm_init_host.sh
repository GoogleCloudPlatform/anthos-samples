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

# [START anthosbaremetal_resources_abm_init_host]

##############################################################################
# Commands starting with leading double underscores (__) nand ending with
# double underscores denote functions defined in this script.
##############################################################################
DATE=$(date)
HOSTNAME=$(hostname)

function __main__ () {
  echo "[$DATE] Init script running for host $HOSTNAME"
  __print_separator__
  __setup_kubctl__
  __setup_bmctl__
  __setup_kind__
  __setup_openstack__
  __setup_docker__
  echo "[+] Successfully completed initialization of host $HOSTNAME"
}


##############################################################################
# Install the kubectl CLI for interaction with the cluster
##############################################################################
function __setup_kubctl__ () {
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/sbin/
  __check_exit_status__ $? \
    "[+] Successfully installed kubectl." \
    "[-] Failed to install kubectl."
  __print_separator__
}

##############################################################################
# Install the bmctl CLI for managing the Anthos cluster
##############################################################################
function __setup_bmctl__ () {
  gcloud storage cp gs://anthos-baremetal-release/bmctl/"${ABM_VERSION}"/linux-amd64/bmctl .
  chmod a+x bmctl
  sudo mv bmctl /usr/local/sbin/
  __check_exit_status__ $? \
    "[+] Successfully installed bmctl." \
    "[-] Failed to install bmctl."
  __print_separator__
}

##############################################################################
# Install docker
##############################################################################
function __setup_docker__ () {
  cd ~ || return
  echo "Installing docker"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sudo usermod -aG docker abm
  newgrp docker
  __check_exit_status__ $? \
    "[+] Successfully installed docker." \
    "[-] Failed to install docker."
  __print_separator__
}

##############################################################################
# Install the kind CLI for debugging the bootstrap cluster
##############################################################################
function __setup_kind__ () {
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
  chmod +x kind
  sudo mv ./kind /usr/local/sbin/
  __check_exit_status__ $? \
    "[+] Successfully installed kind." \
    "[-] Failed to install kind."
  __print_separator__
}

##############################################################################
# Install the OpenStack CLI for configuring OpenStack K8s Cloud provider
##############################################################################
function __setup_openstack__ () {
  sudo apt install python3-openstackclient -y
  __check_exit_status__ $? \
    "[+] Successfully installed openstack cli client." \
    "[-] Failed to install openstack cli client."
  __print_separator__
}

function __check_exit_status__ () {
  EXIT_CODE=$1
  SUCCESS_MSG=$2
  FAILURE_MSG=$3

  if [ "$EXIT_CODE" -eq 0 ]
  then
    echo "$SUCCESS_MSG"
  else
    echo "$FAILURE_MSG" >&2
    exit "$EXIT_CODE"
  fi
}

function __print_separator__ () {
  echo "------------------------------------------------------------------------------"
}

# Run the script from main()
__main__ "$@"

# [END anthosbaremetal_resources_abm_init_host]
