#!/bin/bash

CLUSTER_NAME=$1

UNSET=$1

if [[ -z "${CLUSTER_NAME}" ]]; then

    echo "Please supply a gke-hub cluster name"
    echo -e "\ngateway-connect.sh <clusterName> <optional true>\n"
    exit 1
fi

COMMAND="set"

if [[ ! -z "${UNSET}" ]]; then
    COMMAND="unset"
fi

gcloud config ${COMMAND} auth/impersonate_service_account gateway-connect-agent@${PROJECT_ID}.iam.gserviceaccount.com
gcloud beta container hub memberships get-credentials $CLUSTER_NAME
