#!/bin/bash

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
source "${PREFIX_DIR}/cloud/gce-helper.vars"

if [[ ! -f "./build-artifacts/consumer-edge-machine.pub" ]]; then
    echo "ERROR: SSH key used to communicate with remote machines does not exist. Please setup key and place the public key here: './build-artifacts/consumer-edge-machine.pub'"
    exit 1
fi

SSH_KEY="./build-artifacts/consumer-edge-machine.pub"

if [[ ! -z $1 ]]; then
    # any parameter passed will trigger ONLY the /etc/hosts format for cnucs
    display_ip_host_format
else
    display_gce_vms_ips "${SSH_KEY}"
fi
