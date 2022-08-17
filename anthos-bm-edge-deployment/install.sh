#!/bin/bash

# Requirements
# - Need to have gcloud setup and configured to target $PROJECT_ID
# - Need to have run ./scripts/create-primary-gsa.sh and have the JSON key placed in ./build-artifacts

# Need to generate or validate
# - Create GCE instances (or verify communication with them)
# - Inventory files (cloud/physical)
# - Environment variables (via .envrc)


# verify all ready for install
# - All hosts are reachable with passwordless SSH
# - All environment varaibles have been defined
# docker run -v "$(pwd):/var/consumer-edge-install:ro" -it gcr.io/${GCP_PROJECT}/consumer-edge-install:latest /bin/bash -c /var/consumer-edge-install/scripts/health-check.sh

### Run docker
# docker pull gcr.io/${GCP_PROJECT}/consumer-edge-install:latest
### NOTE: Use this in the "verify" section above
# docker run -v "$(pwd):/var/consumer-edge-install:ro" -it gcr.io/${GCP_PROJECT}/consumer-edge-install:latest /bin/bash -c /var/consumer-edge-install/scripts/health-check.sh


# Run installation (command could be run manually too or instead)
# docker run -v "$(pwd):/var/consumer-edge-install:ro" -it gcr.io/${GCP_PROJECT}/consumer-edge-install:latest /bin/bash -c ansible-playbook -i inventory all-full-install.yaml

ERROR="\e[31m"
INFO="\e[32m"
WARN="\e[1;33m"
DEBUG="\e[1;33m"
ENDCOLOR="\e[0m"

function pretty_print() {
    MSG=$1
    LEVEL=${2:-INFO}

    if [[ -z "${MSG}" ]]; then
        return
    fi

    case "$LEVEL" in
        "ERROR")
            echo -e $(printf "${ERROR}${MSG}$ENDCOLOR")
            ;;
        "WARN")
            echo -e $(printf "${WARN}${MSG}$ENDCOLOR")
            ;;
        "INFO")
            echo -e $(printf "${INFO}${MSG}$ENDCOLOR")
            ;;
        "DEBUG")
            echo -e $(printf "${DEBUG}${MSG}$ENDCOLOR")
            ;;
        *)
            echo "NO MATCH"
            ;;
    esac
}



echo -e "===============================================\nThis is a script to manage the installation of the Consumer Edge for Cloud (GCE) demo instances.\n==============================================="

## Check State of system

ERROR=0
if [[ ! -x $(command -v gcloud) ]]; then
    prett_print "ERROR: gcloud (Google Cloud SDK) command is required, but not installed." "ERROR"
    ERROR=1
else
    pretty_print "PASS: gcloud command found"
fi

if [[ ! -x $(command -v envsubst) ]]; then
    pretty_print "WARN: envsubst (gettext) command is optional and may be used, but not installed." "WARN"
else
    pretty_print "PASS: envsubst command found"
fi

if [[ ! -x $(command -v ssh-keygen) ]]; then
    pretty_print "ERROR: ssh-keygen (SSH) command is required, but not installed. Please install OpenSSH" "ERROR"
    ERROR=1
else
    pretty_print "PASS: ssh-keygen command found"
fi


if [[ "${ERROR}" -eq 1 ]]; then
    echo "Required applications are not present on this host machine. Please install and re-try"
    exit 1
fi

# reset for configuration errors
ERROR=0

# Check for SSH Keys
if [[ ! -f "./build-artifacts/consumer-edge-machine.encrypted" || ! -f "./build-artifacts/consumer-edge-machine.pub" ]]; then
    pretty_print "ERROR: Encrypted SSH Key './build-artifacts/consumer-edge-machine.encrypted' and/or './build-artifacts/consumer-edge-machine.pub' were not found, did you generate them or encrypt the private key?" "ERROR"
    exit 1
else
    pretty_print "PASS: SSH Keys found"
fi

# Check for GSA Keys
if [[ ! -f "./build-artifacts/consumer-edge-gsa.json" ]]; then
    pretty_print "ERROR: GSA JSON key './build-artifacts/consumer-edge-gsa.json' does not exist, please generate a key using ./script/create-primary-gsa.sh and try again." "ERROR"
    exit 1
else
    pretty_print "PASS: GSA Key found"
fi

# Check for GCP Inventory
if [[ ! -f "./inventory/gcp.yml" ]]; then
    pretty_print "WARNING: GCP Inventory file was not found. IF using GCE instances, this file MUST be setup and working." "WARN"
else
    pretty_print "PASS: GCP Inventory file found"
fi

# Check for GCP Inventory
if [[ ! -f "./inventory/inventory.yaml" ]]; then
    pretty_print "WARNING: Physical Inventory file was not found. IF using physical devices, this file MUST be setup and working." "WARN"
else
    pretty_print "PASS: Physical inventory file found"
fi

# Check for GSA Keys
if [[ ! -f "./.envrc" ]]; then
    pretty_print "ERROR: Environment variables file .envrc was not found or is not accessible." "ERROR"
    exit 1
else
    pretty_print "PASS: Environment variables (.envrc) file found"
fi

# Check for GCR docker credentials helper
HAS_GCR=$(cat ${HOME}/.docker/config.json | grep "gcloud")

if [[ -z "${HAS_GCR}" ]]; then
    pretty_print "Authorizing docker for gcr.io"
    gcloud auth configure-docker --quiet --verbosity=critical --no-user-output-enabled
fi

# Check for SSH Keys
if [[ -z "${PROJECT_ID}" ]]; then
    pretty_print "ERROR: Environment variable 'PROJECT_ID' does not exist, please set and try again." "ERROR"
    exit 1
else
    pretty_print "PASS: PROJECT_ID (${PROJECT_ID}) variable is set."
fi

if [[ -z "${LOCAL_GSA_FILE}" ]]; then
    pretty_print "ERROR: An environment variable pointing to the local GSA key file does not exist. Please run ./scripts/create-primary-gsa.sh and place the key as ./build-artifacts/consumer-edge-gsa.json" "ERROR"
    ERROR=1
elif [[ ! -f $LOCAL_GSA_FILE ]]; then
    pretty_print "ERROR: Local GSA file does not exist or is not placed where the ENV is pointing to." "ERROR"
    ERROR=1
else
    pretty_print "PASS: Local GSA key (${LOCAL_GSA_FILE})"
fi

if [[ -z "${SCM_TOKEN_USER}" ]]; then
    pretty_print "ERROR: Gitlab personal access token variable for USER is not set. Please refer to 'Pre Installation Steps'" "ERROR"
    ERROR=1
else
    pretty_print "PASS: SCM_TOKEN_USER (${SCM_TOKEN_USER}) variable is set."
fi

if [[ -z "${SCM_TOKEN_TOKEN}" ]]; then
    pretty_print "ERROR: Gitlab personal access token variable for TOKEN is not set. Please refer to 'Pre Installation Steps'" "ERROR"
    ERROR=1
else
    pretty_print "PASS: SCM_TOKEN_TOKEN (${SCM_TOKEN_TOKEN}) variable is set."
fi

if [[ -z "${ROOT_REPO_TYPE}" ]]; then
    pretty_print "PASS: Using token based SCM authention."
elif [[ "${ROOT_REPO_TYPE}" != "gcpserviceaccount" ]]; then  # TODO: This is quick and dirty, not comprehensive to the other types that *could* be used (token, ssh, etc)
    pretty_print "ERROR: Repo Type is set to but not to 'gcpserviceaccount'" "ERROR"
    ERROR=1
else
    pretty_print "PASS: Using GCP GSA based SCM authention with GSR"
fi

if [[ -z "${ROOT_REPO_URL}" ]]; then
    pretty_print "ERROR: Root Repo URL has not been set." "ERROR"
    ERROR=1
else
    pretty_print "PASS: Root Repo is set to: (${ROOT_REPO_URL})"
fi

if [[ "${ERROR}" -eq 1 ]]; then
    echo "Required configurations are not present in their intended location. Please re-configure and re-try again."
    exit 1
fi

echo ""
read -p "Check the values above and if correct, do you want to proceed? (y/N): " proceed

if [[ "${proceed}" =~ ^([yY][eE][sS]|[yY])$ ]]; then

    pretty_print "Starting the installation"

    pretty_print "Pulling docker install image..."


    RESULT=$(docker pull gcr.io/${PROJECT_ID}/consumer-edge-install:latest)

    if [[ $? -gt 0 ]]; then
        pretty_print "ERROR: Cannot pull Consumer Edge Install image"
        exit 1
    fi

    pretty_print " "
    pretty_print "=============================="
    pretty_print "Starting the docker container. You will need to run the following 2 commands (cut-copy-paste)"
    pretty_print "=============================="
    pretty_print "1: ./scripts/health-check.sh"
    pretty_print "2: ansible-playbook all-full-install.yml -i inventory"
    pretty_print "3: Type 'exit' to exit the Docker shell after installation"
    pretty_print "=============================="
    pretty_print "Thank you for using the quick helper script!"
    pretty_print "(you are now inside the Docker shell)"
    pretty_print " "

    # Running docker image
    docker run -e PROJECT_ID="${PROJECT_ID}" -v "$(pwd):/var/consumer-edge-install:ro" -it gcr.io/${PROJECT_ID}/consumer-edge-install:latest

    if [[ $? -gt 0 ]]; then
        pretty_print "ERROR: Docker container cannot open."
        exit 1
    fi

else
    echo "Canceling"
    exit 0
fi