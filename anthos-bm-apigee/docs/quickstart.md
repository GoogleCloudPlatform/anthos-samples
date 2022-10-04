## Quick starter

### Setup the bare metal infrastructure

1. Create a Service Aaccount with Owner Role and download the key file. Activate the Service Account. If you have executed ./resources/run_prerequisite.sh , verify that you have the key file downloaded and service account is created with right permission.
```
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create baremetal-owner
gcloud iam service-accounts keys create anthos-bm-owner.json --iam-account=baremetal-owner@$PROJECT_ID.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:baremetal-owner@$PROJECT_ID.iam.gserviceaccount.com --role=roles/owner
gcloud auth activate-service-account --key-file anthos-bm-owner.json
```

2. Clone this repo into the workstation from where the rest of this guide will be followed
3. Update the `terraform.tfvars.sample` file to include variables specific to your environment
```
project_id                = "<GOOGLE_CLOUD_PROJECT_ID>"
region                    = "<GOOGLE_CLOUD_REGION_TO_USE>"
zone                      = "<GOOGLE_CLOUD_ZONE_TO_USE>"
credentials_file          = "<PATH_TO_GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE>"
admin_vm_service_account  = "<SERVICE ACCOUNT EMAIL WITH OWNER PERMISSION>"
#mode                     = "install"
```
Uncomment the mode to make installation in auto mode. More about that in section [here](./one_click_install.md).

An example of these configuration looks like this below:

```
project_id                     = "anthos-bm-example4"
region                         = "us-central1"
zone                           = "us-central1-a"
credentials_file               = "anthos-bm-owner.json"
admin_vm_service_account       = "baremetal-owner@anthos-bm-example4.iam.gserviceaccount.com"
mode                           = "install"
```

4. Rename the `variables` file to default name used by Terraform for the `variables` file:
> **Note:** You can skip this step if you run `terraform apply` with the `-var-file` flag
```sh
mv terraform.tfvars.sample terraform.tfvars
```

5. Navigate to the root directory of this repository initialize it as a Terraform directory
```sh
# this sets up the required Terraform state management configurations, similar to 'git init'
terraform init
```

6. Create a _Terraform_ execution plan
```sh
# compares the state of the resources, verifies the scripts and creates an execution plan
terraform plan
```

7. Apply the changes described in the _Terraform_ script
```sh
# executes the plan on the given provider (i.e: GCP) to reach the desired state of resources
terraform apply
```
> **Note:** When prompted to confirm the Terraform plan, type 'Yes' and enter

***The `apply` command sets up the Compute Engine VM based bare metal infrastructure. This can take a few minutes (approx. 3-5 mins) for the entire bare-metal cluster to be setup.***

---
### Deploy an Anthos cluster

After the Terraform execution completes you are ready to deploy an Anthos cluster.

1. SSH into the admin host
```sh
gcloud compute ssh tfadmin@apigee-hybrid-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
```

2. Install the Anthos cluster on the provisioned Compute Engine VM based bare metal infrastructure
```sh
sudo ./run_initialization_checks.sh && \
sudo bmctl create config -c apigee-hybrid && \
sudo cp ~/apigee-hybrid.yaml bmctl-workspace/apigee-hybrid && \
sudo bmctl create cluster -c apigee-hybrid && \
./install_apigee.sh
```
---

Running the commands from the Terraform output starts setting up a new Anthos cluster. This includes checking the initialization state of the nodes, creating the admin and user clusters and also registering the cluster with Google Cloud using [Connect](https://cloud.google.com/anthos/multicluster-management/connect/overview). The whole setup can take up to 30 minutes. You see the following output as the cluster is being created:

> **Note:** The logs for checks on node initialization has been left out. They appear before the following logs from Anthos setup

```sh
Created config: bmctl-workspace/apigee-hybrid/apigee-hybrid.yaml
Creating bootstrap cluster... OK
Installing dependency components... OK
Waiting for preflight check job to finish... OK
- Validation Category: machines and network
        - [PASSED] 10.200.0.3
        - [PASSED] 10.200.0.4
        - [PASSED] 10.200.0.5
        - [PASSED] 10.200.0.6
        - [PASSED] 10.200.0.7
        - [PASSED] gcp
        - [PASSED] node-network
Flushing logs... OK
Applying resources for new cluster
Waiting for cluster to become ready OK
Writing kubeconfig file
kubeconfig of created cluster is at bmctl-workspace/apigee-hybrid/apigee-hybrid-kubeconfig, please run
kubectl --kubeconfig bmctl-workspace/apigee-hybrid/apigee-hybrid-kubeconfig get nodes
to get cluster node status.
Please restrict access to this file as it contains authentication credentials of your cluster.
Waiting for node pools to become ready OK
Moving admin cluster resources to the created admin cluster
Flushing logs... OK
Deleting bootstrap cluster... OK
Operation "operations/acat.p2-739559844142-7d29aafc-49d2-47c6-9dd4-4342352c04bd" finished successfully.
Operation "operations/acat.p2-739559844142-79d3808d-6a03-4cbf-ba17-6e8208ecd321" finished successfully.
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   654  100   654    0     0   4192      0 --:--:-- --:--:-- --:--:--  4192
100 38.7M  100 38.7M    0     0  51.0M      0 --:--:-- --:--:-- --:--:-- 51.0M
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io configured
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io configured
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io configured
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io configured
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io configured
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io configured
namespace/cert-manager configured
serviceaccount/cert-manager-cainjector unchanged
serviceaccount/cert-manager unchanged
serviceaccount/cert-manager-webhook unchanged
clusterrole.rbac.authorization.k8s.io/cert-manager-cainjector unchanged
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-issuers unchanged
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers unchanged
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-certificates unchanged
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-orders unchanged
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-challenges configured
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim configured
clusterrole.rbac.authorization.k8s.io/cert-manager-view configured
clusterrole.rbac.authorization.k8s.io/cert-manager-edit configured
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-cainjector unchanged
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-issuers unchanged
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers unchanged
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-certificates unchanged
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-orders unchanged
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-challenges unchanged
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim unchanged
role.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection unchanged
role.rbac.authorization.k8s.io/cert-manager:leaderelection unchanged
role.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving unchanged
rolebinding.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection unchanged
rolebinding.rbac.authorization.k8s.io/cert-manager:leaderelection configured
rolebinding.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving configured
service/cert-manager unchanged
service/cert-manager-webhook unchanged
deployment.apps/cert-manager-cainjector configured
deployment.apps/cert-manager configured
deployment.apps/cert-manager-webhook configured
mutatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook configured
validatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook configured
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 40.6M  100 40.6M    0     0   152M      0 --:--:-- --:--:-- --:--:--  152M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    96    0     3  100    93      2     62  0:00:01  0:00:01 --:--:--    63
{}
fetching package "/asm" from "https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages" to "asm"
automatically set 30 field(s) for setter "gcloud.core.project" to value "anthos-bm-example5" in package "asm" derived from gcloud config
automatically set 2 field(s) for setter "gcloud.project.projectNumber" to value "739559844142" in package "asm" derived from gcloud config
asm/
set 30 field(s) of setter "gcloud.core.project" to value "anthos-bm-example5"
asm/
set 2 field(s) of setter "gcloud.project.projectNumber" to value "739559844142"
asm/
set 20 field(s) of setter "gcloud.container.cluster" to value "apigee-hybrid"
asm/
set 20 field(s) of setter "gcloud.compute.location" to value "global"
asm/
set 6 field(s) of setter "anthos.servicemesh.hub" to value "gcr.io/gke-release/asm"
asm/
set 6 field(s) of setter "anthos.servicemesh.rev" to value "asm-1106-2"
asm/
set 6 field(s) of setter "anthos.servicemesh.tag" to value "1.10.6-asm.2"
asm/
set 5 field(s) of setter "gcloud.project.environProjectNumber" to value "739559844142"
asm/
set 5 field(s) of setter "anthos.servicemesh.hubTrustDomain" to value "anthos-bm-example5.svc.id.goog"
asm/
set 2 field(s) of setter "anthos.servicemesh.hub-idp-url" to value "https://gkehub.googleapis.com/projects/anthos-bm-example5/locations/global/memberships/apigee-hybrid"

- Processing resources for Istio core.
✔ Istio core installed
- Processing resources for Istiod.
- Processing resources for Istiod. Waiting for Deployment/istio-system/istiod-asm-1106-2
✔ Istiod installed
- Processing resources for Ingress gateways.
- Processing resources for Ingress gateways. Waiting for Deployment/istio-system/istio-ingressgat...
✔ Ingress gateways installed
- Pruning removed resources
✔ Installation completeThank you for installing Istio 1.10.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/KjkrDnMPByq7akrYA
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 5186k  100 5186k    0     0   187M      0 --:--:-- --:--:-- --:--:--  187M
apigeectl_1.7.0-390442d_linux_64/COPYRIGHT
apigeectl_1.7.0-390442d_linux_64/LICENSE
apigeectl_1.7.0-390442d_linux_64/README.md
apigeectl_1.7.0-390442d_linux_64/VERSION.txt
apigeectl_1.7.0-390442d_linux_64/config/values.yaml
apigeectl_1.7.0-390442d_linux_64/examples/embeddedasm
apigeectl_1.7.0-390442d_linux_64/examples/network-policy
apigeectl_1.7.0-390442d_linux_64/examples/overrides-large.yaml
apigeectl_1.7.0-390442d_linux_64/examples/overrides-medium.yaml
apigeectl_1.7.0-390442d_linux_64/examples/overrides-small.yaml
apigeectl_1.7.0-390442d_linux_64/examples/private-overrides.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/apigee-operators
apigeectl_1.7.0-390442d_linux_64/plugins/apigee-operators/apigee-envoyfilter.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/apigee-operators/apigee-operators.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/apigee-operators/apigee-resources.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/diagnostic
apigeectl_1.7.0-390442d_linux_64/plugins/diagnostic/diagnostic-collector.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/README.md
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/apigee-ca-issuer.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/apigee-istiod-certificate.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/envoyfilter-1.11.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/ingress-role-binding.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/ingress-role.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/ingress-service-account.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/istio-config.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/istiod-cluster-role-binding.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/istiod-cluster-role.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/istiod-deployment-with-apigee-controller.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/istiod-service-account.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/istiod-svc.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/localTesting
apigeectl_1.7.0-390442d_linux_64/plugins/istiod/localTesting/istiod-deployment-static-config.yaml
apigeectl_1.7.0-390442d_linux_64/plugins/open-shift
apigeectl_1.7.0-390442d_linux_64/plugins/open-shift/scc.yaml
apigeectl_1.7.0-390442d_linux_64/templates/0_init-peerauthentication.yaml
apigeectl_1.7.0-390442d_linux_64/templates/0_init.yaml
apigeectl_1.7.0-390442d_linux_64/templates/1_apigee-datastore.yaml
apigeectl_1.7.0-390442d_linux_64/templates/1_apigee-redis.yaml
apigeectl_1.7.0-390442d_linux_64/templates/2_apigee-organization.yaml
apigeectl_1.7.0-390442d_linux_64/templates/3_apigee-environments.yaml
apigeectl_1.7.0-390442d_linux_64/templates/4_apigee-telemetries.yaml
apigeectl_1.7.0-390442d_linux_64/templates/virtualhosts.yaml
apigeectl_1.7.0-390442d_linux_64/tools/apigee-pull-push.sh
apigeectl_1.7.0-390442d_linux_64/tools/common.sh
apigeectl_1.7.0-390442d_linux_64/tools/create-service-account
apigeectl_1.7.0-390442d_linux_64/tools/dump_kubernetes.sh
apigeectl_1.7.0-390442d_linux_64/apigeectl
/home/tfadmin/apigee_workspace/apigeectl
ERROR: (gcloud.iam.service-accounts.delete) NOT_FOUND: Unknown service account

[INFO]: Creating service account apigee-non-prod@anthos-bm-example5.iam.gserviceaccount.com with roles roles/logging.logWriter roles/monitoring.metricWriter roles/storage.objectAdmin roles/apigee.analyticsAgent roles/apigee.synchronizerManager roles/apigeeconnect.Agent roles/apigee.runtimeAgent   in directory ./service-accounts

[INFO]: Checking if service account already exists

[INFO]: Service account does not exist. Creating...
Created service account [apigee-non-prod].
apigee-non-prod@anthos-bm-example5.iam.gserviceaccount.com

[INFO]: Successfully created service account apigee-non-prod@anthos-bm-example5.iam.gserviceaccount.com

[INFO]: Downloading service accounts in directory ./service-accounts
created key [cb270d79fb793b2dfbc949fbdb334b50163211dc] of type [json] as [./service-accounts/anthos-bm-example5-apigee-non-prod.json] for [apigee-non-prod@anthos-bm-example5.iam.gserviceaccount.com]

[INFO]: JSON Key apigee-non-prod was successfully download to directory /home/tfadmin/apigee_workspace/hybrid-files/tools.
Updated IAM policy for project [anthos-bm-example5].
Updated IAM policy for project [anthos-bm-example5].
Updated IAM policy for project [anthos-bm-example5].
Updated IAM policy for project [anthos-bm-example5].
Updated IAM policy for project [anthos-bm-example5].
Updated IAM policy for project [anthos-bm-example5].
Updated IAM policy for project [anthos-bm-example5].
ROLE
roles/apigee.analyticsAgent
roles/apigee.runtimeAgent
roles/apigee.synchronizerManager
roles/apigeeconnect.Agent
roles/logging.logWriter
roles/monitoring.metricWriter
roles/storage.objectAdmin

[INFO]: Successfully updated roles for apigee-non-prod@anthos-bm-example5.iam.gserviceaccount.com
Generating a RSA private key
.............................................+++++
.........................................................................................................................+++++
writing new private key to './certs/keystore.key'
-----
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   488    0   315  100   173    943    517 --:--:-- --:--:-- --:--:--  1461
Waiting for initial 60 seconds ....
Checking Operations :  f0f36d10-5b33-4ba7-82cb-a0ae029634fc
ERROR: gcloud crashed (KeyError): 'organizations'

If you would like to report this issue, please run the following command:
  gcloud feedback

To check gcloud for common problems, please run the following command:
  gcloud info --run-diagnostics
Checking Operations :  f0f36d10-5b33-4ba7-82cb-a0ae029634fc
ERROR: gcloud crashed (KeyError): 'organizations'

If you would like to report this issue, please run the following command:
  gcloud feedback

To check gcloud for common problems, please run the following command:
  gcloud info --run-diagnostics
Checking Operations :  f0f36d10-5b33-4ba7-82cb-a0ae029634fc
ERROR: gcloud crashed (KeyError): 'organizations'

If you would like to report this issue, please run the following command:
  gcloud feedback

To check gcloud for common problems, please run the following command:
  gcloud info --run-diagnostics
Checking Operations :  f0f36d10-5b33-4ba7-82cb-a0ae029634fc
ERROR: gcloud crashed (KeyError): 'organizations'

If you would like to report this issue, please run the following command:
  gcloud feedback

To check gcloud for common problems, please run the following command:
  gcloud info --run-diagnostics
Checking Operations :  f0f36d10-5b33-4ba7-82cb-a0ae029634fc
Using Apigee organization `anthos-bm-example5`
Checking Operations :  f0f36d10-5b33-4ba7-82cb-a0ae029634fc
Using Apigee organization `anthos-bm-example5`
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   418    0   333  100    85   1839    469 --:--:-- --:--:-- --:--:--  2309
Checking Operations :  eb6531a0-0640-4dec-9588-8d3101166076
Using Apigee organization `anthos-bm-example5`
Checking Operations :  eb6531a0-0640-4dec-9588-8d3101166076
Using Apigee organization `anthos-bm-example5`
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   631    0   551  100    80   5349    776 --:--:-- --:--:-- --:--:--  6126
Checking Operations :  f1cb6258-282a-49aa-8fc2-0fd1883a3192
Using Apigee organization `anthos-bm-example5`
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   622    0   585  100    37   5625    355 --:--:-- --:--:-- --:--:--  6038
storageclass.storage.k8s.io/standard patched
--2022-04-17 16:04:15--  https://github.com/mikefarah/yq/releases/download/v4.24.2/yq_linux_amd64
Resolving github.com (github.com)... 140.82.112.4
Connecting to github.com (github.com)|140.82.112.4|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://objects.githubusercontent.com/github-production-release-asset-2e65be/43225113/cf8e37bd-cbbb-47c8-9057-7eefcdd67791?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220417%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220417T160415Z&X-Amz-Expires=300&X-Amz-Signature=f7bd1d401b0c550382ae995a4cff9f3cc102b0e3ade3102df5706d463c620340&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=43225113&response-content-disposition=attachment%3B%20filename%3Dyq_linux_amd64&response-content-type=application%2Foctet-stream [following]
--2022-04-17 16:04:15--  https://objects.githubusercontent.com/github-production-release-asset-2e65be/43225113/cf8e37bd-cbbb-47c8-9057-7eefcdd67791?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220417%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220417T160415Z&X-Amz-Expires=300&X-Amz-Signature=f7bd1d401b0c550382ae995a4cff9f3cc102b0e3ade3102df5706d463c620340&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=43225113&response-content-disposition=attachment%3B%20filename%3Dyq_linux_amd64&response-content-type=application%2Foctet-stream
Resolving objects.githubusercontent.com (objects.githubusercontent.com)... 185.199.111.133, 185.199.110.133, 185.199.109.133, ...
Connecting to objects.githubusercontent.com (objects.githubusercontent.com)|185.199.111.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 10156456 (9.7M) [application/octet-stream]
Saving to: ‘yq_linux_amd64’

     0K .......... .......... .......... .......... ..........  0% 4.37M 2s
    50K .......... .......... .......... .......... ..........  1% 5.51M 2s
   100K .......... .......... .......... .......... ..........  1% 22.3M 1s
   150K .......... .......... .......... .......... ..........  2% 30.5M 1s
  9900K .......... ........                                   100%  194M=0.1s

2022-04-17 16:04:15 (86.4 MB/s) - ‘yq_linux_amd64’ saved [10156456/10156456]

./service-accounts/anthos-bm-example5-apigee-non-prod.json
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   224    0   132  100    92    200    139 --:--:-- --:--:-- --:--:--   339
{
  "identities": [
    "serviceAccount:apigee-non-prod@anthos-bm-example5.iam.gserviceaccount.com"
  ],
  "etag": "BwXc28vKwJk="
}
/home/tfadmin/apigee_workspace/apigeectl
namespace/apigee created
namespace/apigee-system created
Parsing file: config/values.yaml
Parsing file: overrides/overrides.yaml
validating GCP and Apigee org settings
Validating organization "anthos-bm-example5" exists in project "anthos-bm-example5"

Invoking "kubectl apply" with pre-init YAML config...

peerauthentication.security.istio.io/apigee-system created
peerauthentication.security.istio.io/apigee created
priorityclass.scheduling.k8s.io/high-priority created
namespace/apigee-system configured
namespace/apigee configured
serviceaccount/apigee-init created
clusterrole.rbac.authorization.k8s.io/apigee-init created
clusterrolebinding.rbac.authorization.k8s.io/apigee-init created
secret/apigee-datastore-default-creds created
secret/apigee-redis-default-creds created
Warning: resource namespaces/apigee-system is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
Warning: resource namespaces/apigee is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.

deleting an existing envoyfilter before creating new one for supporting asm upgrade...


finish cleaning up existing envoyfilter.


Waiting for cert manager's pods to be running before proceeding (usually its webhook takes ~3 mins to come up completely)...
Please re-run *init* again if this times out....(Also, check the health of cert manager components before the re-run)...

deployment.apps/cert-manager condition met
deployment.apps/cert-manager-cainjector condition met
deployment.apps/cert-manager-webhook condition met

All init jobs are complete, proceeding...


Invoking "kubectl apply" with final init YAML config...

envoyfilter.networking.istio.io/apigee-envoyfilter-1-8 serverside-applied
envoyfilter.networking.istio.io/apigee-envoyfilter-1-9 serverside-applied
envoyfilter.networking.istio.io/apigee-envoyfilter-1-10 serverside-applied
envoyfilter.networking.istio.io/apigee-envoyfilter-1-11 serverside-applied
envoyfilter.networking.istio.io/apigee-envoyfilter-1-12 serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeedatastores.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeedeployments.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeeenvironments.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeeorganizations.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeeredis.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeerouteconfigs.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeeroutes.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/apigeetelemetries.apigee.cloud.google.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/cassandradatareplications.apigee.cloud.google.com serverside-applied
role.rbac.authorization.k8s.io/apigee-leader-election-role serverside-applied
clusterrole.rbac.authorization.k8s.io/apigee-manager-role serverside-applied
clusterrole.rbac.authorization.k8s.io/apigee-proxy-role serverside-applied
rolebinding.rbac.authorization.k8s.io/apigee-leader-election-rolebinding serverside-applied
clusterrolebinding.rbac.authorization.k8s.io/apigee-manager-rolebinding serverside-applied
clusterrolebinding.rbac.authorization.k8s.io/apigee-proxy-rolebinding serverside-applied
service/apigee-controller-manager-metrics-service serverside-applied
service/apigee-webhook-service serverside-applied
deployment.apps/apigee-controller-manager serverside-applied
certificate.cert-manager.io/apigee-serving-cert serverside-applied
issuer.cert-manager.io/apigee-selfsigned-issuer serverside-applied
mutatingwebhookconfiguration.admissionregistration.k8s.io/apigee-mutating-webhook-configuration serverside-applied
validatingwebhookconfiguration.admissionregistration.k8s.io/apigee-validating-webhook-configuration serverside-applied
serviceaccount/apigee serverside-applied
clusterrole.rbac.authorization.k8s.io/apigee serverside-applied
clusterrolebinding.rbac.authorization.k8s.io/apigee serverside-applied
configmap/apigee-config serverside-applied
job.batch/apigee-resources-install serverside-applied
Parsing file: config/values.yaml
Parsing file: overrides/overrides.yaml
validating GCP and Apigee org settings
Validating organization "anthos-bm-example5" exists in project "anthos-bm-example5"
cleansing older AD's (v1alpha1) istio resources...

Validating "ConnectAgent" IAM permissions against project "anthos-bm-example5"

Validating "UDCA" IAM permissions against project "anthos-bm-example5"

Validating "Apigee Runtime Agent" IAM permissions against project "anthos-bm-example5"

Validating "Synchronizer" IAM permissions against project "anthos-bm-example5"

Validating "UDCA" IAM permissions against project "anthos-bm-example5"

Validating "Metrics" IAM permissions against project "anthos-bm-example5"

Invoking "kubectl apply" with YAML config...

peerauthentication.security.istio.io/apigee-system unchanged
peerauthentication.security.istio.io/apigee unchanged
apigeedatastore.apigee.cloud.google.com/default created
apigeeredis.apigee.cloud.google.com/default created
secret/apigee-mart-anthos-bm-examp-b7f9175-svc-account created
secret/apigee-connect-agent-anthos-bm-examp-b7f9175-svc-account created
secret/apigee-udca-anthos-bm-examp-b7f9175-svc-account created
secret/apigee-watcher-anthos-bm-examp-b7f9175-svc-account created
secret/anthos-bm-examp-b7f9175-ax-salt created
secret/anthos-bm-examp-b7f9175-encryption-keys created
secret/anthos-bm-examp-b7f9175-data-encryption created
apigeeorganization.apigee.cloud.google.com/anthos-bm-examp-b7f9175 created
secret/apigee-synchronizer-anthos-bm-examp-test-deb4c56-svc-account created
secret/apigee-udca-anthos-bm-examp-test-deb4c56-svc-account created
secret/apigee-runtime-anthos-bm-examp-test-deb4c56-svc-account created
secret/anthos-bm-examp-test-deb4c56-encryption-keys created
apigeeenvironment.apigee.cloud.google.com/anthos-bm-examp-test-deb4c56 created
secret/apigee-metrics-svc-account created
apigeetelemetry.apigee.cloud.google.com/apigee-telemetry created
secret/anthos-bm-example5-default-test created
apigeerouteconfig.apigee.cloud.google.com/anthos-bm-example5-default-test created
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Apigee is Ready
Anthos on bare metal installation complete!
Run [export KUBECONFIG=/home/tfadmin/bmctl-workspace/apigee-hybrid/apigee-hybrid-kubeconfig] to set the kubeconfig
Run the [/home/tfadmin/login.sh] script to generate a token that you can use to login to the cluster from the Google Cloud Console
```

---
### Verify and interacting with the Baremetal cluster

You can find your cluster's `kubeconfig` file on the admin machine in the `bmctl-workspace` directory. To verify your deployment, complete the following steps

1. SSH into the admin host _(if you are not already inside it)_:
```sh
# You can copy the command from the output of Terraform run from the previous step
gcloud compute ssh tfadmin@apigee-hybrid-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
```

2. Set the `KUBECONFIG` environment variable with the path to the cluster's configuration file to run `kubectl` commands on the cluster.
```sh
export CLUSTER_ID=apigee-hybrid
export KUBECONFIG=$HOME/bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID-kubeconfig
kubectl get nodes
```

You should see the nodes of the cluster printed, _similar_ to the output below:
```sh
NAME          STATUS   ROLES    AGE   VERSION
apigee-hybrid-abm-cp1-001   Ready    master   17m   v1.18.6-gke.6600
apigee-hybrid-abm-w1-001    Ready    <none>   14m   v1.18.6-gke.6600
apigee-hybrid-abm-w2-001    Ready    <none>   14m   v1.18.6-gke.6600
apigee-hybrid-abm-w3-001    Ready    <none>   14m   v1.18.6-gke.6600
apigee-hybrid-abm-w4-001    Ready    <none>   14m   v1.18.6-gke.6600
```


#### Interacting with the cluster via the GCP console

During the setup process, your cluster will be auto-registered in Google Cloud using [Connect](https://cloud.google.com/anthos/multicluster-management/connect/overview). In order to interact with the cluster from the GCP console you must first ***login*** to the cluster.

The [Logging into the Anthos bare metal cluster](login.md) explains how you can do it.

---


### Cleanup

You can cleanup the cluster setup in two ways:

#### 1. Using Terraform

- First deregister the cluster before deleting all the resources created by Terraform
  ```sh
  # SSH into the admin host
  gcloud compute ssh tfadmin@apigee-hybrid-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>

  # Reset the cluster
  export CLUSTER_ID=apigee-hybrid
  export KUBECONFIG=$HOME/bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID-kubeconfig
  sudo bmctl reset --cluster $CLUSTER_ID

  # logout of the admin host
  exit
  ```

- Then, use Terraform to delete all resources.
  ```sh
  # to be run from the root directory of this repo
  terraform destroy --auto-approve
  ```
 - Deregister cluster from the Cloud hub membership.

#### 2. Delete the entire Google Cloud project
- Directly [delete the project](https://console.cloud.google.com/cloud-resource-manager) from the console

#### 3. Delete Apigee Organization
 ```sh
     gcloud alpha apigee organizations delete <YOUR_PROJECT>
 ```
#### 4. Clean Temporary files
- Clean temporary files 
```sh
    rm -fr ./resources/.temp
    rm -fr terraform.tfstate
```
