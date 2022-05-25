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

KSA_NAME=edge-sa

echo "-------------------------------------------------------------------"
echo "💡 Creating Kubernetes ClusterRole: cloud-console-reader"
echo "-------------------------------------------------------------------"
cat <<EOF > cloud-console-reader.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cloud-console-reader
rules:
- apiGroups: [""]
  resources: ["nodes", "persistentvolumes"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "list", "watch"]
EOF
kubectl apply -f cloud-console-reader.yaml

echo "-------------------------------------------------------------------"
echo "💡 Creating Kubernetes Service Account (KSA): ${KSA_NAME}"
echo "-------------------------------------------------------------------"
kubectl create serviceaccount ${KSA_NAME}

echo "-------------------------------------------------------------------"
echo "💡 Creating Kubernetes ClusterRoleBindings for KSA ${KSA_NAME}"
echo "-------------------------------------------------------------------"
kubectl create clusterrolebinding edge-sa-view-binding \
  --clusterrole view --serviceaccount default:${KSA_NAME}
kubectl create clusterrolebinding edge-sa-console-reader-binding \
  --clusterrole cloud-console-reader --serviceaccount default:${KSA_NAME}
kubectl create clusterrolebinding another-binding \
  --clusterrole cluster-admin --serviceaccount default:${KSA_NAME}

echo "-------------------------------------------------------------------"
echo "💡 Retrieving Kubernetes Service Account Token"
SECRET_NAME=${KSA_NAME}-token

kubectl apply -f - << __EOF__
apiVersion: v1
kind: Secret
metadata:
  name: "${SECRET_NAME}"
  annotations:
    kubernetes.io/service-account.name: "${KSA_NAME}"
type: kubernetes.io/service-account-token
__EOF__

until [[ $(kubectl get -o=jsonpath="{.data.token}" "secret/${SECRET_NAME}") ]]; do
  echo "waiting for token..." >&2;
  sleep 1;
done

TOKEN=$(kubectl get secret "${SECRET_NAME}" -o jsonpath='{$.data.token}' | base64 --decode)

echo ""
echo "🚀 ------------------------------TOKEN-------------------------------- 🚀"
echo "$TOKEN"
echo "🚀 ------------------------------------------------------------------- 🚀"
