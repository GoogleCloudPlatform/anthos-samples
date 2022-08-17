#! /bin/bash
# Use gcloud to pull active project Id
export PROJECT_ID=$(gcloud projects list --format=json | jq -r ".[0] .projectId")
export ZONE="us-west1-b"

read -p "Is the GCP Zone $ZONE acceptable for deployment? (Y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Edit this file to modify ZONE. Ensure ./templates/envrc-template.sh matches."
    exit 1
fi

gcloud config set compute/zone $ZONE

# Disable Policies without Constraints
gcloud beta resource-manager org-policies disable-enforce compute.requireShieldedVm --project=$PROJECT_ID
gcloud beta resource-manager org-policies disable-enforce compute.requireOsLogin --project=$PROJECT_ID
gcloud beta resource-manager org-policies disable-enforce iam.disableServiceAccountKeyCreation --project=$PROJECT_ID
gcloud beta resource-manager org-policies disable-enforce iam.disableServiceAccountKeyUpload --project=$PROJECT_ID
gcloud beta resource-manager org-policies disable-enforce iam.disableServiceAccountCreation --project=$PROJECT_ID
gcloud beta resource-manager org-policies disable-enforce iam.automaticIamGrantsForDefaultServiceAccounts --project=$PROJECT_ID
gcloud beta resource-manager org-policies disable-enforce compute.disableNestedVirtualization --project=$PROJECT_ID

# now loop and fix policies with  constraints in Argolis 
# Inner Loop - Loop Through Policies with Constraints
declare -a policies=("constraints/compute.trustedImageProjects"
 "constraints/compute.vmExternalIpAccess"
 "constraints/compute.restrictSharedVpcSubnetworks"
 "constraints/compute.restrictSharedVpcHostProjects" 
 "constraints/compute.restrictVpcPeering"
 "constraints/compute.vmCanIpForward")

for policy in "${policies[@]}"
do
cat <<EOF > new_policy.yaml
constraint: $policy
listPolicy:
 allValues: ALLOW
EOF
    gcloud resource-manager org-policies set-policy new_policy.yaml --project=$PROJECT_ID
done

# make "default" network check to see if it doesnt exist
# ensure non-conflicting CIDR - ... set to automatic

NETWORK="default"
HAS_NETWORK=$(gcloud compute networks list --filter="name~${NETWORK}" --format="value(name)")

if [[ -z "${HAS_NETWORK}" ]]; then
	gcloud compute networks create "${NETWORK}" \
		--subnet-mode=auto \
		--bgp-routing-mode=regional
else
	echo "Skipping creating network ${NETWORK}, already exists"
fi

# Create default FW rules - assume 0.0.0.0/0 for all entries below
declare -a global_firewall_rules=(
	"gdc-allow-kubectl|tcp:6443"
	"gdc-allow-iap-traffic|tcp:22,tcp:80,tcp:443,tcp:3389"
	"gdc-allow-icmp|icmp"
)
# Create default FW fules - assume 10.0.0.0/8 for all entries below
declare -a internal_firewall_rules=(
	"gdc-allow-internal|tcp:0-65535,udp:0-65535,icmp"
)

# Loop to implement global FW rules
for fw_rule in "${global_firewall_rules[@]}"
do
	# IFS='|' read -r -a array <<< "name1|name2|name3"; echo ${array[0]} ${array[1]} ${array[2]}
	# Above outpues "name1 name2 name3"
	IFS="|" read -r -a array <<< "$fw_rule"
	echo "gcloud compute firewall-rules create ${array[0]} --allow ${array[1]}"
	gcloud compute firewall-rules create ${array[0]} --allow ${array[1]}
done

# Loop to implement 10.0.0.0/8 FW rules for internal access
for fw_rule in "${internal_firewall_rules[@]}"
do
	# IFS='|' read -r -a array <<< "name1|name2|name3"; echo ${array[0]} ${array[1]} ${array[2]}
	# Above outpues "name1 name2 name3"
	IFS="|" read -r -a array <<< "$fw_rule"
	echo "gcloud compute firewall-rules create ${array[0]} --allow ${array[1]} --source-ranges='10.0.0.0/8'"
	gcloud compute firewall-rules create ${array[0]} --allow ${array[1]} --source-ranges="10.0.0.0/8"
done



# Create Bastion Host
echo "Create Bastion Host"
gcloud compute instances create bastion-1 --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --zone="${ZONE}" \
    --network-interface=network-tier=PREMIUM,subnet=default --metadata=enable-oslogin=true \
    --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/cloud-platform \
    --create-disk=mode=rw,size=40,type=projects/${PROJECT_ID}/zones/${ZONE}/diskTypes/pd-balanced \
    --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
    --reservation-affinity=any --provisioning-model=SPOT


##Ready to run ./setup.sh
echo "Ready to run ./setup.sh"
