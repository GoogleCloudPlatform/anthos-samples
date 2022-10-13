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

project=$(gcloud config get-value project)
export  project

enable_services() {
	echo "Enabling Google Cloud APIs..."
	gcloud services enable \
		cloudresourcemanager.googleapis.com \
		compute.googleapis.com \
		apigee.googleapis.com \
		iam.googleapis.com
}

apply_constraints() {
	echo "Applying organization policies to ${project}..."
	gcloud beta resource-manager org-policies disable-enforce compute.requireShieldedVm --project="${project}"
	gcloud beta resource-manager org-policies disable-enforce compute.requireOsLogin --project="${project}"
	gcloud beta resource-manager org-policies disable-enforce iam.disableServiceAccountCreation --project="${project}"
	gcloud beta resource-manager org-policies disable-enforce iam.disableServiceAccountKeyCreation --project="${project}"
	gcloud beta resource-manager org-policies disable-enforce compute.skipDefaultNetworkCreation --project="${project}"

	declare -a policies=("constraints/compute.trustedImageProjects"
		"constraints/compute.vmExternalIpAccess"
		"constraints/compute.restrictSharedVpcSubnetworks"
		"constraints/compute.restrictSharedVpcHostProjects"
		"constraints/compute.restrictVpcPeering"
		"constraints/compute.vmCanIpForward"
	)

	for policy in "${policies[@]}"; do
		cat <<EOF >new_policy.yaml
constraint: $policy
listPolicy:
 allValues: ALLOW
EOF
		gcloud resource-manager org-policies set-policy new_policy.yaml --project="${project}"
	done
	echo "Allow upto 30 seconds to Propagate the policy changes"
	sleep 30
	echo "Policy Changes done"
}

create_network() {
	EXISTS=$(gcloud compute networks list \
		--filter="name=default" \
		--format="value(name)" \
		--project="${project}")

	if [[ -z "${EXISTS}" ]]; then
		echo "Creating default network..."
		gcloud compute networks create default --project="${project}" --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional
		echo "Successfully created default network."
	fi
}

set_firewall_exists() {
	EXISTS=$(gcloud compute firewall-rules list \
		--filter="name=$1 AND network=default" \
		--format="value(name, disabled)" \
		--project="${project}")
}

apply_firewall_policies() {
	echo "Creating default firewall rules on the default network..."
	set_firewall_exists default-allow-ssh
	if [[ -z "${EXISTS}" ]]; then
		gcloud compute firewall-rules create default-allow-ssh --network default --allow tcp:22 --source-ranges 0.0.0.0/0
	fi

	set_firewall_exists default-allow-rdp
	if [[ -z "${EXISTS}" ]]; then
		gcloud compute firewall-rules create default-allow-rdp --network default --allow tcp:3389 --source-ranges 0.0.0.0/0
	fi

	set_firewall_exists default-allow-icmp
	if [[ -z "${EXISTS}" ]]; then
		gcloud compute firewall-rules create default-allow-icmp --network default --allow icmp --source-ranges 0.0.0.0/0
	fi

	set_firewall_exists default-allow-internal
	if [[ -z "${EXISTS}" ]]; then
		gcloud compute firewall-rules create default-allow-internal --network default --allow tcp:0-65535,udp:0-65535,icmp --source-ranges 10.128.0.0/9
	fi

	set_firewall_exists default-allow-out
	if [[ -z "${EXISTS}" ]]; then
		gcloud compute firewall-rules create default-allow-out --direction egress --priority 0 --network default --allow tcp,udp --destination-ranges 0.0.0.0/0
	fi
}

create_owner_service_account() {
	EXISTS=$(gcloud iam service-accounts list \
		--filter="email=baremetal-owner@"${project}".iam.gserviceaccount.com" \
		--format="value(name, disabled)" \
		--project="${project}")

	if [[ -z "${EXISTS}" ]]; then
		echo "Creating Service Account with Owner and Apigee.Admin roles..."
		gcloud iam service-accounts create baremetal-owner
		gcloud projects add-iam-policy-binding "${project}" --member=serviceAccount:baremetal-owner@"${project}".iam.gserviceaccount.com --role=roles/owner
		gcloud projects add-iam-policy-binding "${project}" --member=serviceAccount:baremetal-owner@"${project}".iam.gserviceaccount.com --role=roles/apigee.admin
	fi

	if [ ! -f "anthos-bm-owner.json" ]; then
		gcloud iam service-accounts keys create anthos-bm-owner.json --iam-account=baremetal-owner@"${project}".iam.gserviceaccount.com
		gcloud auth activate-service-account --key-file anthos-bm-owner.json
	fi
}

enable_services
apply_constraints
create_network
apply_firewall_policies
create_owner_service_account
