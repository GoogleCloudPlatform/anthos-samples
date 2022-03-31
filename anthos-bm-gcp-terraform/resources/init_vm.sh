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

# [START anthosbaremetal_resources_init_vm]

##############################################################################
# Commands starting with leading double underscores (__) nand ending with
# double underscores denote functions defined in this script.
##############################################################################

ZONE=$(cut -d "=" -f2- <<< "$(grep < init.vars ZONE)")
IS_ADMIN_VM=$(cut -d "=" -f2- <<< "$(grep < init.vars IS_ADMIN_VM)")
VXLAN_IP_ADDRESS=$(cut -d "=" -f2- <<< "$(grep < init.vars VXLAN_IP_ADDRESS)")
SERVICE_ACCOUNT=$(cut -d "=" -f2- <<< "$(grep < init.vars SERVICE_ACCOUNT)")
HOSTNAMES=$(cut -d "=" -f2- <<< "$(grep < init.vars HOSTNAMES)")
VM_INTERNAL_IPS=$(cut -d "=" -f2- <<< "$(grep < init.vars VM_INTERNAL_IPS)")
LOG_FILE=$(cut -d "=" -f2- <<< "$(grep < init.vars LOG_FILE)")
DEFAULT_IFACE=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | xargs)

DATE=$(date)
HOSTNAME=$(hostname)

##############################################################################
# Entrypoint to the startup_script. Runs all the necessary steps to configure
# the host; also ensures admin specific setup is done for admin hosts
##############################################################################
function __main__ () {
  echo "[$DATE] Init script running for host $HOSTNAME"
  __print_separator__

  __install_deps__
  __setup_vxlan__
  __disable_apparmour__
  __setup_admin_host__

  echo "[+] Successfully completed initialization of host $HOSTNAME"
}

##############################################################################
# Install some basic dependencies required for the setup
##############################################################################
function __install_deps__ () {
  apt-get -qq update
  apt-get -qq install -y jq

  __check_exit_status__ $? \
    "[+] Successfully installed dependencies" \
    "[-] Failed to install dependencies. Check for failures on [apt-get] in ~/$LOG_FILE"
  __print_separator__
}

##############################################################################
# Setup a new network device for the overlay vxlan network connecting all the
# hosts in the cluster. This adds this host to an L2 overlay network
##############################################################################
function __setup_vxlan__ () {
  echo "Setting up ip address [$VXLAN_IP_ADDRESS/24] for net device vxlan0"
  ip link add vxlan0 type vxlan id 42 dev "$DEFAULT_IFACE" dstport 0
  __check_exit_status__ $? \
    "[+] Successfully added a new network device of type vxlan" \
    "[-] Failed to add new network device for vxlan setup. Check for failures on [ip link add] in ~/$LOG_FILE"

  __update_bridge_entries__

  ip addr add "$VXLAN_IP_ADDRESS"/24 dev vxlan0
  __check_exit_status__ $? \
    "[+] Successfully associated ip address $VXLAN_IP_ADDRESS/24 to the new vxlan network interface" \
    "[-] Failed to associate ip address $VXLAN_IP_ADDRESS/24 to the new vxlan network interface. Check for failures on [ip addr add] in ~/$LOG_FILE"

  ip link set up dev vxlan0
  __check_exit_status__ $? \
    "[+] Successfully started the new network device vxlan0" \
    "[-] Failed to start the new network device vxlan0. Check for failures on [ip link set up] in ~/$LOG_FILE"

  __print_separator__
}

##############################################################################
# Update the host's linux bridge to include forwarding entries for each of
# the hosts in the cluster. The bridge entries are populated using the VPC
# internal IPs of the hosts in the cluster.
##############################################################################
function __update_bridge_entries__ () {
  current_ip=$(ip --json a show dev "$DEFAULT_IFACE" | jq '.[0].addr_info[0].local' -r)

  echo "Cluster VM IPs retreived => $VM_INTERNAL_IPS"
  for ip in ${VM_INTERNAL_IPS//|/ }
  do
    if [ "$ip" != "$current_ip" ]; then
      bridge fdb append to 00:00:00:00:00:00 dst "$ip" dev vxlan0
      __check_exit_status__ $? \
        "[+] Successfully added forwarding entry on bridge for ip [$ip]" \
        "[-] Failed to add forwarding entry on bridge for ip [$ip]. Check for failures on [bridge fdb append] in ~/$LOG_FILE"
    else
      echo "Skipping bridge forwarding entry setup for ip [$ip]"
    fi
  done
  __print_separator__
}

##############################################################################
# Disable apparmour service on the host. Anthos clusters on bare metal does
# not support apparmor
##############################################################################
function __disable_apparmour__ () {
  echo "Stopping apparmor system service"
  systemctl stop apparmor.service
  __check_exit_status__ $? \
    "[+] Successfully stopped apparmor service" \
    "[-] Failed to stop apparmor service. Check for failures on [systemctl stop apparmor.service] in ~/$LOG_FILE"

  systemctl disable apparmor.service
  __check_exit_status__ $? \
    "[+] Successfully disabled apparmor service" \
    "[-] Failed to disable apparmor service. Check for failures on [systemctl disable apparmor.service] in ~/$LOG_FILE"

  __print_separator__
}

##############################################################################
# Configure the admin host with additional tools required to provision and
# manage the Anthos cluster. This is only executed inside the admin host.
##############################################################################
function __setup_admin_host__ () {
  if [ "$IS_ADMIN_VM" == "true" ]; then
    echo "Configuring admin workstation for host $HOSTNAME."
    __setup_service_account__
    __setup_kubctl__
    __setup_bmctl__
    __setup_docker__
    __setup_ssh_access__
  else
    echo "Host $HOSTNAME is not an admin workstation."
  fi
}

##############################################################################
# Download the service account key in order to configure the Anthos cluster
##############################################################################
function __setup_service_account__ () {
  PROJECT_ID=$(gcloud config get-value project)
  gcloud iam service-accounts keys create /root/bm-gcr.json --iam-account="${SERVICE_ACCOUNT}"@"${PROJECT_ID}".iam.gserviceaccount.com
  __check_exit_status__ $? \
    "[+] Successfully downloaded key for service account [$SERVICE_ACCOUNT]" \
    "[-] Failed to download key for service account [$SERVICE_ACCOUNT]. Check for failures on [gcloud iam service-accounts] in ~/$LOG_FILE"

  __print_separator__
}

##############################################################################
# Install the kubectl CLI for interaction with the cluster
##############################################################################
function __setup_kubctl__ () {
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv kubectl /usr/local/sbin/
  __check_exit_status__ $? \
    "[+] Successfully installed kubectl" \
    "[-] Failed to install kubectl. Check for failures on downloading or moving kubctl to /usr/local/sbin/ in ~/$LOG_FILE"

  __print_separator__
}

##############################################################################
# Install the bmctl CLI for managing the Anthos cluster
##############################################################################
function __setup_bmctl__ () {
  mkdir baremetal && cd baremetal || return
  gsutil cp gs://anthos-baremetal-release/bmctl/1.10.2/linux-amd64/bmctl .
  chmod a+x bmctl
  mv bmctl /usr/local/sbin/
  __check_exit_status__ $? \
    "[+] Successfully installed bmctl" \
    "[-] Failed to install bmctl. Check for failures on downloading or moving bmctl to /usr/local/sbin/ in ~/$LOG_FILE"

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
  __check_exit_status__ $? \
    "[+] Successfully installed docker" \
    "[-] Failed to install docker. Check for failures on downloading or execution of [get-docker.sh] in ~/$LOG_FILE"

  __print_separator__
}

##############################################################################
# Setup SSH access from the admin host to all the other hosts in the cluster.
# The gcloud CLI is used here update the SSH key information on the hosts.
##############################################################################
function __setup_ssh_access__ () {
  ssh-keygen -t rsa -N "" -f "$HOME"/.ssh/id_rsa
  __check_exit_status__ $? \
    "[+] Successfully generated SSH key pair" \
    "[-] Failed to generate SSH key pair. Check for failures on [ssh-keygen] in ~/$LOG_FILE"

  sed "s/ssh-rsa/$USER:ssh-rsa/" ~/.ssh/id_rsa.pub > ssh-metadata
  for hostname in ${HOSTNAMES//|/ }
  do
    gcloud compute instances add-metadata "$hostname" --zone "${ZONE}" --metadata-from-file ssh-keys=ssh-metadata
    __check_exit_status__ $? \
      "[+] Successfully copied ssh-key to host [$hostname]" \
      "[-] Failed to copy ssh-key to host [$hostname]. Check for failures on [gcloud compute instances add-metadata] in ~/$LOG_FILE"
  done
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

# [END anthosbaremetal_resources_init_vm]
