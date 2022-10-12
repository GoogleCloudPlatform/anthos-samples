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

# [START anthosbaremetal_resources_install_abm]

DIR=$(pwd)
INSTALL_MODE=$(cut -d "=" -f2- <<< "$(grep < init.vars INSTALL_MODE)")
CLUSTER_ID=$(cut -d "=" -f2- <<< "$(grep < init.vars CLUSTER_ID)")
NFS_SERVER=$(cut -d "=" -f2- <<< "$(grep < init.vars NFS_SERVER)")
TERRAFORM_SA_PATH=$(cut -d "=" -f2- <<< "$(grep < init.vars TERRAFORM_SA_PATH)")

export GOOGLE_APPLICATION_CREDENTIALS="$TERRAFORM_SA_PATH"
gcloud auth activate-service-account --key-file "$TERRAFORM_SA_PATH"

# run the initialization checks
"$DIR"/run_initialization_checks.sh
# create a new workspace and config file for the Anthos bare metal cluster
bmctl create config -c "$CLUSTER_ID"
# copy the prefilled configuration file into the new workspace
cp "$DIR/$CLUSTER_ID".yaml "$DIR/bmctl-workspace/$CLUSTER_ID"
# create the Anthos bare metal cluster
bmctl create cluster -c "$CLUSTER_ID"

# check is the cluster creation succeeded
EXITCODE=$?
if [ "$EXITCODE" -ne 0 ]; then
    echo "[-] Failed to create Anthos on bare metal cluster!"
    exit $EXITCODE
fi

KUBECONFIG_PATH="$DIR/bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID-kubeconfig"
echo ""
echo "[+] Anthos on bare metal installation complete!"
echo "[+] Run [export KUBECONFIG=$KUBECONFIG_PATH] to set the kubeconfig"
echo "[+] Run the [$DIR/login.sh] script to generate a token that you can use to login to the cluster from the Google Cloud Console"
echo ""

# Configure NFS is enabled
if [ "$NFS_SERVER" == "true" ]; then
  # Install NFS CSI Driver
  KUBECONFIG="$KUBECONFIG_PATH" bash -c 'curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v3.1.0/deploy/install-driver.sh | bash -s v3.1.0 --'
  # Configure nfs-csi storageClass
  kubectl --kubeconfig "$KUBECONFIG_PATH" apply -f "$DIR"/nfs-csi.yaml

  echo ""
  echo "[+] Configuring NFS Container Storage Interface complete!"
  echo "[+] You may utilize with [storageClassName: nfs-csi]"
  echo ""
fi

# if the install mode is not 'manuallb' then skip the steps that follow
if [ "$INSTALL_MODE" = "install" ]; then
    exit $EXITCODE
fi

echo "[+] Configuring the istio ingress for public access..."
# read the necessary variables from the init.vars file
echo "[+] Extracting necessary variables from the init.vars file"
ZONE=$(cut -d "=" -f2- <<< "$(grep < init.vars ZONE)")
CONTROLPLAN_VM_NAMES=$(cut -d "=" -f2- <<< "$(grep < init.vars CONTROLPLAN_VM_NAMES)")
INGRESS_LB_IP=$(cut -d "=" -f2- <<< "$(grep < init.vars INGRESS_LB_IP)")
INGRESS_NEG=$(cut -d "=" -f2- <<< "$(grep < init.vars INGRESS_NEG)")
FIREWALL_NAME=$(cut -d "=" -f2- <<< "$(grep < init.vars FIREWALL_NAME)")
FIREWALL_PORTS=$(cut -d "=" -f2- <<< "$(grep < init.vars FIREWALL_PORTS)")

# retrieve the NodePort for http connections on the istio-ingress service
echo "[+] Fetching the NodePort of the istio-ingress service in the cluster"
NODEPORT=$(kubectl \
    --kubeconfig "$KUBECONFIG_PATH" \
    --namespace gke-system get service/istio-ingress \
    --output jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
FIREWALL_PORTS="$FIREWALL_PORTS,tcp:$NODEPORT"
echo "[+] Firewall ports to be updated: $FIREWALL_PORTS"

# create a patch file to update the istio-ingress service with the LB IP
echo "[+] Creating the patch file for istio-ingress at: /tmp/ingress-patch.yaml"
cat <<EOF > /tmp/ingress-patch.yaml
spec:
  externalIPs:
    - ${INGRESS_LB_IP}
EOF

# update the istio-ingress service with the patch, so it has the external IP
echo "[+] Patching the istio-ingress service with the external ip: $INGRESS_LB_IP"
kubectl patch \
    --kubeconfig "$KUBECONFIG_PATH" \
    --namespace gke-system service/istio-ingress \
    --patch-file /tmp/ingress-patch.yaml

# deploy the Point of Sale application manifest found in the anthos-samples repo
echo "[+] Deploying the Point of Sale application manifests"
kubectl apply \
    --kubeconfig "$KUBECONFIG_PATH" \
    -f https://raw.githubusercontent.com/GoogleCloudPlatform/anthos-samples/main/anthos-bm-gcp-terraform/resources/manifests/point-of-sale.yaml

# create an ingress to route traffic to the api-server of the Point of Sale app
echo "[+] Deploying the ingress resource for the Point of Sale application"
kubectl apply \
    --kubeconfig "$KUBECONFIG_PATH" \
    -f https://raw.githubusercontent.com/GoogleCloudPlatform/anthos-samples/main/anthos-bm-gcp-terraform/resources/manifests/pos-ingress.yaml

# update the ingress loadbalancer's network-endpoint-group to include the
# controlplane node IPs and NodePorts
echo "[+] Updating the Network Endpoint Group (NEG) of the Ingress loadbalancer with the controlPlaneIP:nodePort"
for host in ${CONTROLPLAN_VM_NAMES//|/ }
do
    echo "[+] Adding network endpoint [instance=$host,port=$NODEPORT] to NEG group [$INGRESS_NEG]"
    gcloud compute network-endpoint-groups update "${INGRESS_NEG}" \
        --zone="${ZONE}" \
        --add-endpoint "instance=$host,port=$NODEPORT"
done

# update the firewall to include the http NodePort of the istio-ingress service
echo "[+] Updating firewall rule allow traffic to the ingress nodePort: $FIREWALL_PORTS"
gcloud compute firewall-rules update "$FIREWALL_NAME" --allow="$FIREWALL_PORTS"

echo ""
echo "[*] Configuring Ingress Loadbalancer complete!"
echo "[*] You may reach the services exposed by the ingress at: $INGRESS_LB_IP"
echo ""

# [END anthosbaremetal_resources_install_abm]
