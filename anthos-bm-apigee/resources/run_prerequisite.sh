#!/bin/bash

export project=$(gcloud config get-value project)

enable_services() {
	gcloud services enable \
		cloudresourcemanager.googleapis.com \
		compute.googleapis.com \
		apigee.googleapis.com
}

apply_constraints() {
	gcloud beta resource-manager org-policies disable-enforce compute.requireShieldedVm --project=${project}
	gcloud beta resource-manager org-policies disable-enforce compute.requireOsLogin --project=${project}
	gcloud beta resource-manager org-policies disable-enforce iam.disableServiceAccountCreation --project=${project}
	gcloud beta resource-manager org-policies disable-enforce iam.disableServiceAccountKeyCreation --project=${project}
	gcloud beta resource-manager org-policies disable-enforce compute.skipDefaultNetworkCreation --project=${project}

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
	echo "Creating default Network"
	gcloud compute networks create default --project=$project --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional
	echo "default Network is Created"
}

apply_firewall_policies() {
	echo "Creating Firewall rules"
	gcloud compute firewall-rules create default-allow-ssh --network default --allow tcp:22 --source-ranges 0.0.0.0/0
	gcloud compute firewall-rules create default-allow-rdp --network default --allow tcp:3389 --source-ranges 0.0.0.0/0
	gcloud compute firewall-rules create default-allow-icmp --network default --allow icmp --source-ranges 0.0.0.0/0
	gcloud compute firewall-rules create default-allow-internal --network default --allow tcp:0-65535,udp:0-65535,icmp --source-ranges 10.128.0.0/9
	gcloud compute firewall-rules create default-allow-out --direction egress --priority 0 --network default --allow tcp,udp --destination-ranges 0.0.0.0/0

}

create_owner_service_account() {
	echo "Creating Owner Service Account"
	gcloud iam service-accounts create baremetal-owner
	gcloud iam service-accounts keys create anthos-bm-owner.json --iam-account=baremetal-owner@${project}.iam.gserviceaccount.com
	gcloud projects add-iam-policy-binding ${project} --member=serviceAccount:baremetal-owner@${project}.iam.gserviceaccount.com --role=roles/owner
	gcloud auth activate-service-account --key-file anthos-bm-owner.json

}

enable_services
apply_constraints
create_network
apply_firewall_policies
create_owner_service_account
