#!/bin/bash

###
### GSAs can only have a maximum of 10 GSA keys, and the installation process, with certain parameters, produce new GSA keys, this script removes all GSA keys for the primary agents in the system.
###
### This should ONLY be used when you know the explicit reason why you're doing this
###

read -p "This is a destructive operation meant for advanced users only. Proceed? (any character other than 'Y' will exit): " response

if [ "$response" != "Y" ]; then
    echo 'Canceling...'
    exit 0
fi

GSAs=(
    "abm-gke-register-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "abm-cloud-operations-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "abm-gcr-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "abm-gke-connect-agent@${PROJECT_ID}.iam.gserviceaccount.com"
    "external-secrets-k8s@${PROJECT_ID}.iam.gserviceaccount.com"
     )

# gcloud iam service-accounts keys create /var/keys/abm-gke-register-agent-creds.json --iam-account=abm-gke-register-agent@anthos-bare-metal-lab-1.iam.gserviceaccount.com --project=anthos-bare-metal-lab-1

for GSA in "${GSAs[@]}"
do
    KEYS=( $(gcloud iam service-accounts keys list --iam-account=$GSA --format="value(name)" --managed-by="user" --project="${PROJECT_ID}") )
    echo "Removing ${#KEYS[@]} keys for: $GSA"
    for KEY in "${KEYS[@]}"
    do
        gcloud iam service-accounts keys delete $KEY --iam-account=$GSA --quiet --project="${PROJECT_ID}"
    done
    # # Remove the Secret Manager version (disable it)
    GSA_SECRET_KEY_NAME="${GSA%%@*}"

    SECRET_VERSIONS=( $(gcloud secrets versions list ${GSA_SECRET_KEY_NAME} --format="value(name)" --filter=state=enabled) )
    for SECRET_VERSION in "${SECRET_VERSIONS[@]}"
    do
        gcloud secrets versions disable "${SECRET_VERSION}" --secret="${GSA_SECRET_KEY_NAME}"
    done
done