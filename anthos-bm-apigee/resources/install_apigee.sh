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

wait_for_active() {
	operations_id=$1
	if [ "$operations_id" != null ]; then
		echo "Checking Operations : $operations_id"
		status=$(gcloud alpha apigee operations describe "$operations_id" --format=json | jq -r .response.state)
		while [ "$status" != "ACTIVE" ]; do
			sleep 30
			echo "Checking Operations : $operations_id"
			status=$(gcloud alpha apigee operations describe "$operations_id" --format=json | jq -r .response.state)
		done
	fi
}

create_workspace() {
	export KUBECONFIG=$PWD/bmctl-workspace/apigee-cluster/apigee-cluster-kubeconfig
	echo "export KUBECONFIG=$KUBECONFIG" >>~/.bashrc
	echo "export KUBECONFIG=$KUBECONFIG" >>/home/tfadmin/.bashrc
	mkdir apigee_workspace
	cd apigee_workspace || exit
	export APIGEE_WORKSPACE=$PWD
}

install_cert_manager() {
	kubectl apply \
	        --validate=false \
	        -f https://github.com/jetstack/cert-manager/releases/download/v1.7.2/cert-manager.yaml
}

download_asm() {
	cd "$APIGEE_WORKSPACE" || exit
	curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.12 >asmcli
	chmod +x asmcli

}

install_asm() {
	cd "$APIGEE_WORKSPACE" || exit
	fleet_id=$(gcloud config get-value project)
	echo "$KUBECONFIG"
	echo "$fleet_id"
	./asmcli install \
	        --fleet_id "${fleet_id}" \
	        --kubeconfig "$KUBECONFIG" \
	        --output_dir . \
	        --custom_overlay overlay.yaml \
	        --platform multicloud \
	        --enable_all \
	        --option legacy-default-ingressgateway
}

create_overlay_asm() {
	cd "$APIGEE_WORKSPACE" || exit
	cat <<EOF >overlay.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
        k8s:
          nodeSelector:
            # default node selector, if different or not using node selectors, change accordingly.
            #cloud.google.com/gke-nodepool: apigee-runtime
          resources:
            requests:
              cpu: 1000m
          service:
            type: LoadBalancer
            ports:
              - name: http-status-port
                port: 15021
              - name: http2
                port: 80
                targetPort: 8080
              - name: https
                port: 443
                targetPort: 8443
  meshConfig:
    accessLogFormat:
      '{"start_time":"%START_TIME%","remote_address":"%DOWNSTREAM_DIRECT_REMOTE_ADDRESS%","user_agent":"%REQ(USER-AGENT)%","host":"%REQ(:AUTHORITY)%","request":"%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%","request_time":"%DURATION%","status":"%RESPONSE_CODE%","status_details":"%RESPONSE_CODE_DETAILS%","bytes_received":"%BYTES_RECEIVED%","bytes_sent":"%BYTES_SENT%","upstream_address":"%UPSTREAM_HOST%","upstream_response_flags":"%RESPONSE_FLAGS%","upstream_response_time":"%RESPONSE_DURATION%","upstream_service_time":"%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%","upstream_cluster":"%UPSTREAM_CLUSTER%","x_forwarded_for":"%REQ(X-FORWARDED-FOR)%","request_method":"%REQ(:METHOD)%","request_path":"%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%","request_protocol":"%PROTOCOL%","tls_protocol":"%DOWNSTREAM_TLS_VERSION%","request_id":"%REQ(X-REQUEST-ID)%","sni_host":"%REQUESTED_SERVER_NAME%","apigee_dynamic_data":"%DYNAMIC_METADATA(envoy.lua)%"}'
EOF

}

install_apigee_ctl() {
	cd "$APIGEE_WORKSPACE" || exit
	VERSION=$(curl -s \
		https://storage.googleapis.com/apigee-release/hybrid/apigee-hybrid-setup/current-version.txt?ignoreCache=1)
        export VERSION
	#Pinning down to previous version because 1.7 has some issues
	export VERSION="1.7.3"
	curl -LO \
		https://storage.googleapis.com/apigee-release/hybrid/apigee-hybrid-setup/$VERSION/apigeectl_linux_64.tar.gz

	tar -xvf apigeectl_linux_64.tar.gz
	mv apigeectl_$VERSION-* apigeectl

}

setup_project_directory() {
	cd "$APIGEE_WORKSPACE/apigeectl" || exit
	export APIGEECTL_HOME=$PWD
	echo "$APIGEECTL_HOME"

	cd "$APIGEE_WORKSPACE" || exit
	mkdir hybrid-files
	cd hybrid-files || exit
	mkdir overrides
	mkdir certs
	ln -s "$APIGEECTL_HOME/tools" tools
	ln -s "$APIGEECTL_HOME/config" config
	ln -s "$APIGEECTL_HOME/templates" templates
	ln -s "$APIGEECTL_HOME/plugins" plugins
	#Lets do cleaup first
	PROJECT_ID=$(gcloud config get-value project)
	export PROJECT_ID
	#gcloud iam service-accounts delete  apigee-non-prod@$PROJECT_ID.iam.gserviceaccount.com --quiet
	echo 'y' | ./tools/create-service-account --env non-prod --dir ./service-accounts
	#gcloud iam service-accounts keys create ./service-accounts/$PROJECT_ID-apigee-non-prod.json --iam-account=apigee-non-prod@$PROJECT_ID.iam.gserviceaccount.com --quiet
	INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
	export INGRESS_HOST
	export DOMAIN=$INGRESS_HOST".nip.io"
        # shellcheck disable=SC2086
	openssl req -nodes -new -x509 \
	        -keyout ./certs/keystore.key \
	        -out ./certs/keystore.pem -subj '/CN='$DOMAIN'' \
	        -days 3650

}

setup_org_env() {
	cd "$APIGEE_WORKSPACE" || exit
	TOKEN=$(gcloud auth print-access-token)
	PROJECT_ID=$(gcloud config get-value project)
	export PROJECT_ID
	export ORG_NAME=$PROJECT_ID
	ORG_DISPLAY_NAME="demo-org"
	ORGANIZATION_DESCRIPTION="demo-org"
	export ANALYTICS_REGION=us-central1
	export RUNTIMETYPE=HYBRID
	curl -H "Authorization: Bearer $TOKEN" -X POST -H "content-type:application/json" \
		-d '{
    		"name":"'"$ORG_NAME"'",
    		"displayName":"'"$ORG_DISPLAY_NAME"'",
    		"description":"'"$ORGANIZATION_DESCRIPTION"'",
    		"runtimeType":"'"$RUNTIMETYPE"'",
    		"analyticsRegion":"'"$ANALYTICS_REGION"'"
  	}' -o org.json \
		"https://apigee.googleapis.com/v1/organizations?parent=projects/$PROJECT_ID"

	echo "Waiting for initial 60 seconds ...."
	sleep 60

        # shellcheck disable=SC2002
	operations_id=$(cat org.json | jq -r .name | awk -F "/" '{print $NF}')
	wait_for_active "$operations_id"

	export ENV_NAME=test
	ENV_DISPLAY_NAME="test"
	ENV_DESCRIPTION="test"
	curl -H "Authorization: Bearer $TOKEN" -X POST -H "content-type:application/json" -d '{
    		"name": "'"$ENV_NAME"'",
    		"displayName": "'"$ENV_DISPLAY_NAME"'",
    		"description": "'"$ENV_DESCRIPTION"'"
  	}' -o env.json "https://apigee.googleapis.com/v1/organizations/$ORG_NAME/environments"

        # shellcheck disable=SC2002
	operations_id=$(cat env.json | jq -r .name | awk -F "/" '{print $NF}')
	wait_for_active "$operations_id"

	export ENV_GROUP=default-test
	INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
	export INGRESS_HOST
	export DOMAIN=$INGRESS_HOST".nip.io"

	curl -H "Authorization: Bearer $TOKEN" -X POST -H "content-type:application/json" \
		-d '{
     		"name": "'"$ENV_GROUP"'",
     		"hostnames":["'"$DOMAIN"'"]
   	}' -o envgroup.json \
		"https://apigee.googleapis.com/v1/organizations/$ORG_NAME/envgroups"
	# shellcheck disable=SC2002
	operations_id=$(cat envgroup.json | jq -r .name | awk -F "/" '{print $NF}')
	wait_for_active "$operations_id"

	curl -H "Authorization: Bearer $TOKEN" -X POST -H "content-type:application/json" \
		-d '{
     		"environment": "'"$ENV_NAME"'",
   	}' -o envattach.json \
		"https://apigee.googleapis.com/v1/organizations/$ORG_NAME/envgroups/$ENV_GROUP/attachments"
}

patch_standard_storageclass() {
	kubectl patch storageclass local-shared \
		-p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
}

prepare_overrides_files() {
	cd "$APIGEE_WORKSPACE" || exit
	PROJECT_ID=$(gcloud config get-value project)
	export PROJECT_ID
	wget https://github.com/mikefarah/yq/releases/download/v4.24.2/yq_linux_amd64
	chmod +x yq_linux_amd64
	sudo mv yq_linux_amd64 /usr/local/bin/yq
	cp apigeectl/examples/overrides-small.yaml hybrid-files/overrides/overrides.yaml
	cd hybrid-files/overrides/ || exit
	sed -i '/hostNetwork: false/a \ \ replicaCount: 3' overrides.yaml
	yq -i '.gcp.projectID = env(PROJECT_ID)' overrides.yaml
	yq -i '.org = env(PROJECT_ID)' overrides.yaml
	yq -i '.k8sCluster.name = "apigee-hybrid"' overrides.yaml
	yq -i '.k8sCluster.region = "us-central1-a"' overrides.yaml
	yq -i '.instanceID = "apigee-hybrid-demo"' overrides.yaml
	yq -i '.cassandra.hostNetwork = true' overrides.yaml
	yq -i 'del(.virtualhosts.[].sslSecret)' overrides.yaml
	yq -i '.virtualhosts.[].name = "default-test"' overrides.yaml
	yq -i '.virtualhosts.[].sslCertPath = "./certs/keystore.pem"' overrides.yaml
	yq -i '.virtualhosts.[].sslKeyPath = "./certs/keystore.key"' overrides.yaml

	export SVC_ACCOUNT="./service-accounts/${PROJECT_ID}-apigee-non-prod.json"
	echo "$SVC_ACCOUNT"
	yq -i '.envs.[].serviceAccountPaths.synchronizer = env(SVC_ACCOUNT)' overrides.yaml
	yq -i '.envs.[].serviceAccountPaths.udca = env(SVC_ACCOUNT)' overrides.yaml
	yq -i '.envs.[].serviceAccountPaths.runtime = env(SVC_ACCOUNT)' overrides.yaml
	yq -i '.mart.serviceAccountPath = env(SVC_ACCOUNT)' overrides.yaml
	yq -i '.metrics.serviceAccountPath = env(SVC_ACCOUNT)' overrides.yaml
	yq -i '.connectAgent.serviceAccountPath = env(SVC_ACCOUNT)' overrides.yaml
	yq -i '.watcher.serviceAccountPath = env(SVC_ACCOUNT)' overrides.yaml
	yq e '{"udca" : {"serviceAccountPath" : env(SVC_ACCOUNT)}}' overrides.yaml > tempfile && cat tempfile >> overrides.yaml
	yq e '{"logger" : {"serviceAccountPath" : env(SVC_ACCOUNT)}}' overrides.yaml > tempfile && cat tempfile >>  overrides.yaml

}

enable_synchronizer() {
	cd "$APIGEE_WORKSPACE" || exit
	TOKEN=$(gcloud auth print-access-token)
	PROJECT_ID=$(gcloud config get-value project)
	export PROJECT_ID
	export ORG_NAME=$PROJECT_ID
	curl -X POST -H "Authorization: Bearer ${TOKEN}" \
		-H "Content-Type:application/json" \
		"https://apigee.googleapis.com/v1/organizations/${ORG_NAME}:setSyncAuthorization" \
		-d '{"identities":["'"serviceAccount:apigee-non-prod@${ORG_NAME}.iam.gserviceaccount.com"'"]}'

}

wait_for_apigee_ready() {
	export APIGEECTL_HOME=$APIGEE_WORKSPACE/apigeectl
	cd "$APIGEE_WORKSPACE/hybrid-files/" || exit

	echo "Checking Apigee Containers ..."
	status=$("$APIGEECTL_HOME/apigeectl" check-ready -f overrides/overrides.yaml 2>&1)
	apigee_ready=$(echo "$status" | grep 'All containers are ready.')
	#apigee_ready=""

	while [ "$apigee_ready" == "" ]; do
		sleep 30
		echo "Checking Apigee Containers ..."
		status=$("$APIGEECTL_HOME/apigeectl" check-ready -f overrides/overrides.yaml 2>&1)
		apigee_ready=$(echo "$status" | grep 'All containers are ready.')
	done
	echo "Apigee is Ready"
}

install_runtime() {
	cd "$APIGEE_WORKSPACE/apigeectl" || exit
	export APIGEECTL_HOME=$PWD
	echo "$APIGEECTL_HOME"
	cd "../hybrid-files/" || exit
	kubectl create namespace apigee
	kubectl create namespace apigee-system
	"${APIGEECTL_HOME}/apigeectl" init -f overrides/overrides.yaml
	wait_for_apigee_ready
	"${APIGEECTL_HOME}/apigeectl" apply -f overrides/overrides.yaml
	wait_for_apigee_ready

}

export GOOGLE_APPLICATION_CREDENTIALS=/home/tfadmin/apigee-sa.json
create_workspace
install_cert_manager
download_asm
create_overlay_asm
install_asm
install_apigee_ctl
setup_project_directory
setup_org_env
patch_standard_storageclass
prepare_overrides_files
enable_synchronizer
install_runtime
