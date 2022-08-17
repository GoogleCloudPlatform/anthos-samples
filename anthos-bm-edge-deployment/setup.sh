#! /bin/bash
#Run from inside of either CloudShell or a Bastion VM inside of the same GCP project as the GCP cnuc's
###

read -p "Did you edit Zone/Region in ./templates/envrc-template.sh? (Y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Must currently run as an admin user with org permissions in order to make the changes throughout
# For now this means we will require that the user login via gcloud auth login
# This check will bail if a gserviceaccount is found in use
GSERVICEACCOUNT=$(gcloud auth list --format=json | grep -B 1 ACTIVE | grep gserviceaccount)
if [[ ! -z "${GSERVICEACCOUNT}" ]]; then
	echo "Please login as an admin user account using the following command -- 'gcloud auth login --no-launch-browser'"
	echo "Copy/Paste the link into a browser where you are authenticated with admin level permissions for the project!!"
	exit 1
fi
echo "Beginning Installation!"

sudo apt update
sudo apt -y install screen
echo "termcapinfo xterm* ti@:te@" > .screenrc

sudo apt -y install git
sudo apt -y remove docker docker-engine docker.io containerd runc
sudo apt -y install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
	    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io
sudo apt -y install jq -y
sudo apt -y install unzip direnv
sudo usermod -aG docker $(whoami)
sudo chmod 666 /var/run/docker.sock
echo "Finished Docker setup..."
#mv algsa-key.json creds-gcp.json
##Instal GS
#yes Y | gcloud secrets create gcs-auth-secret
#gcloud secrets versions add gcs-auth-secret --data-file="creds-gcp.json"

echo "Adding direnv hook to bask & allowing direnv for the current direction"
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
direnv allow
source ~/.bashrc

##Begin setting up to run  ./install
if [[ ! -f "./build-artifacts/consumer-edge-machine" ]]; then
	echo "Creating SSH keys consumer-edge-machine"
	ssh-keygen -o -a 100 -t ed25519 -f ./build-artifacts/consumer-edge-machine -N ''
else
	echo "Found existing ./build-artifacts/consumer-edge-machine, skipping creation"
fi

export QL_PROJECT_ID=$(gcloud config get-value project 2> /dev/null)
if [[ -z "${QL_PROJECT_ID}" ]]; then
        echo "Project ID not configured for gcloud. Please set project with 'gcloud config set project <project-id>'"
        exit 1
	else
		echo "QL_PROJECT_ID set to ${QL_PROJECT_ID}"
fi
export QL_ROOT_REPO="https://gitlab.com/gcp-solutions-public/retail-edge/root-repo-edge-workshop"

echo "##Running gcloud config set project $QL_PROJECT_ID"
gcloud config set project $QL_PROJECT_ID
echo "##Running yes Y | gcloud auth configure-docker"
yes Y | gcloud auth configure-docker


envsubst < templates/envrc-template.sh > .envrc
sed -i "s/PROJECT_ID=.*/PROJECT_ID=\"$QL_PROJECT_ID\"/g" .envrc
#sed -i "s,ROOT_REPO_URL=.*,ROOT_REPO_URL=\"$QL_ROOT_REPO\",g" .envrc
source .envrc

yes Y | ./scripts/create-primary-gsa.sh
if [[ ! -f "./build-artifacts/consumer-edge-machine.encrypted" ]]; then
 	echo "Creating consumer-edge-machine.encrypted file"
# 	yes Y | gcloud kms keyrings create gdc-ce-keyring --location=global
 	gcloud kms encrypt --key gdc-ssh-key --keyring gdc-ce-keyring --location global \
 		--plaintext-file build-artifacts/consumer-edge-machine \
 		--ciphertext-file build-artifacts/consumer-edge-machine.encrypted
else
 	echo "Found existing ./build-artifacts/consumer-edge-machine.encrypted, skipping creation"
fi
# Create the 3 cnuc VMs
source .envrc
./scripts/cloud/create-cloud-gce-baseline.sh -c 3

export CONTAINER_URL=$(gcloud container images list --repository=gcr.io/$PROJECT_ID --format="value(name)" --filter="name~consumer-edge-install")
if [[ -z "$CONTAINER_URL" ]]; then
	cd docker-build
	echo "Starting Cloud Build Install Container!"
	gcloud builds submit --config cloudbuild.yaml .
	cd ..
else
	echo "Found exsiting container: $CONTAINER_URL"
fi
source .envrc
envsubst < templates/inventory-cloud-example.yaml > inventory/gcp.yml
##Ready to run ./install.sh
echo "Ready to run !!!"
echo "Execute 'source .envrc; ./install.sh'"
