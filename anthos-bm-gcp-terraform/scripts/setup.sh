#!/bin/bash
DATE=$(date)
ZONE_FLAG="zone"
ADMIN_VM_FLAG="isAdminVm"
HOSTNAMES_FLAG="hostNames"
CLUSTER_VMS="clusterVmIps"
HOSTNAME=$(hostname)
META_DATA=$(echo $HOSTNAME | sed 's|\(.*\)-.*|\1|')
FILE=anthosbm.lock

##############################################################################
# Entrypoint to the startup_script. Ensures that the host setup is run only
# during the first time the vm boots and never again for future reboots
##############################################################################
function main () {
  if [[ -f "$FILE" ]]; then
    echo "[$DATE] $FILE exists; 'setup' script has already been run; hence skipping"
    exit 0
  fi
  echo "[$DATE] Startup script running first time for host $HOSTNAME" >> $FILE
  wait_for_vms
  install_deps
  setup_vxlan
  disable_apparmour
  setup_admin_host
}

##############################################################################
# Wait for the VMs in the cluster to have. They are considered started once
# the metadata for the VM IPs are made available to them by terraform
##############################################################################
function wait_for_vms () {
  META_DATA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://metadata.google.internal/computeMetadata/v1/instance/attributes/$CLUSTER_VMS -H "Metadata-Flavor: Google")
  while [ "$META_DATA_STATUS" == "404" ]; do
    echo "Metadata status [$META_DATA_STATUS Not found]; sleeping for 5 seconds..."
    sleep 5
    META_DATA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://metadata.google.internal/computeMetadata/v1/instance/attributes/$CLUSTER_VMS -H "Metadata-Flavor: Google")
  done
}

##############################################################################
# Install some basic dependencies required for the setup
##############################################################################
function install_deps () {
  apt-get -qq update > /dev/null
  apt-get -qq install -y jq > /dev/null
}

##############################################################################
# Setup a new network device for the overlay vxlan network connecting all the
# hosts in the cluster. The vxlan IP address to use for this specific host is
# provided via a metadata entry by terraform. The metadata entry is the
# hostname minus the last suffix string appended by terraform
#   e.g. hostname = abm-worker1-001 --> metadata = abm-worker1
##############################################################################
function setup_vxlan () {
  VXLAN_IP_ADDRESS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/$META_DATA -H "Metadata-Flavor: Google")
  echo "Setting up ip address [$VXLAN_IP_ADDRESS] for net device vxlan0"

  ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
  update_bridge_entries
  ip addr add $VXLAN_IP_ADDRESS dev vxlan0
  ip link set up dev vxlan0
}

##############################################################################
# Update the host's linux bridge to include forwarding entries for each of
# the hosts in the cluster. The bridge entries are populated using the VPC
# internal IPs of the hosts in the cluster. These IPs are made available to
# the host via a metadata entry (clusterVmIps) by terraform
##############################################################################
function update_bridge_entries () {
  VM_INTERNAL_IPS=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/$CLUSTER_VMS -H "Metadata-Flavor: Google")
  current_ip=$(ip --json a show dev ens4 | jq '.[0].addr_info[0].local' -r)

  echo "Cluster VM IPs retreived => $VM_INTERNAL_IPS"
  for ip in $(echo $VM_INTERNAL_IPS | sed "s/|/ /g")
  do
    if [ "$ip" != "$current_ip" ]; then
      echo "Setting forwarding entry on bridge for ip [$ip]"
      bridge fdb append to 00:00:00:00:00:00 dst $ip dev vxlan0
    else
      echo "Skipping bridge forwarding entry setup for ip [$ip]"
    fi
  done
}

##############################################################################
# Disable apparmour service on the host. Anthos clusters on bare metal does
# not support apparmor
##############################################################################
function disable_apparmour () {
  echo "Stopping apparmor system service"
  systemctl stop apparmor.service
  systemctl disable apparmor.service
}

##############################################################################
# Configure the admin host with additional tools required to provision and
# manage the Anthos cluster. This is only executed inside the admin host. A
# is notified whether it's an admin or not via a metadata entry (isAdminVm) by
# terraform
##############################################################################
function setup_admin_host () {
  IS_ADMIN_VM=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/$ADMIN_VM_FLAG -H "Metadata-Flavor: Google")
  if [ "$IS_ADMIN_VM" == "true" ]; then
    echo "Configuring admin workstation for host $HOSTNAME."
    setup_service_account
    setup_kubctl
    setup_bmctl
    setup_docker
    setup_ssh_access
  else
    echo "Host $HOSTNAME is not an admin workstation."
  fi
}

##############################################################################
# Download the service account key in order to configure the Anthos cluster
##############################################################################
function setup_service_account () {
  PROJECT_ID=$(gcloud config get-value project)
  gcloud iam service-accounts keys create /root/bm-gcr.json --iam-account=baremetal-gcr@${PROJECT_ID}.iam.gserviceaccount.com
}

##############################################################################
# Install the kubectl CLI for interaction with the cluster
##############################################################################
function setup_kubctl () {
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv kubectl /usr/local/sbin/
}

##############################################################################
# Install the bmctl CLI for managing the Anthos cluster
##############################################################################
function setup_bmctl () {
  mkdir baremetal && cd baremetal
  # TODO:: Need to fix this
  gsutil cp gs://anthos-baremetal-release/bmctl/1.6.2/linux-amd64/bmctl .
  chmod a+x bmctl
  mv bmctl /usr/local/sbin/
}

##############################################################################
# Install docker
##############################################################################
function setup_docker () {
  cd ~
  echo "Installing docker"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
}

##############################################################################
# Setup SSH access from the admin host to all the other hosts in the cluster.
# The gcloud CLI is used here and the instance names for other hosts are made
# available to the admin host via a metadata entry (hostNames) by terraform
##############################################################################
function setup_ssh_access () {
  HOSTNAMES=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/$HOSTNAMES_FLAG -H "Metadata-Flavor: Google")
  ZONE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/$ZONE_FLAG -H "Metadata-Flavor: Google")
  ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
  sed 's/ssh-rsa/root:ssh-rsa/' ~/.ssh/id_rsa.pub > ssh-metadata
  for hostname in $(echo $HOSTNAMES | sed "s/|/ /g")
  do
    echo "Copying ssh-key to host [$hostname]"
    gcloud compute instances add-metadata $hostname --zone ${ZONE} --metadata-from-file ssh-keys=ssh-metadata
  done
}

# Run the script from main()
main "$@"
