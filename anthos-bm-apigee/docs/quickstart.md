## Quickstart guide <!-- omit in toc -->

- [Setup the bare metal infrastructure](#setup-the-bare-metal-infrastructure)
- [Deploy an Anthos cluster and Install Apigee](#deploy-an-anthos-cluster-and-install-apigee)
- [Verify Apigee Installation](#verify-apigee-installation)
- [Access with UI via the GCP console](#access-with-ui-via-the-gcp-console)
- [Cleanup](#cleanup)

---
### Setup the bare metal infrastructure

1. Clone this repo into the workstation from where the rest of this guide will
   be followed and move into the `anthos-bm-apigee` sample directory:

    ```sh
    git clone https://github.com/GoogleCloudPlatform/anthos-sample
    cd anthos-bm-apigee
    ```

1. Update the `terraform.tfvars.sample` file to include variables specific to
   your environment:

    ```sh
    project_id                    = "<GOOGLE_CLOUD_PROJECT_ID>"
    region                        = "<GOOGLE_CLOUD_REGION_TO_USE>"
    zone                          = "<GOOGLE_CLOUD_ZONE_TO_USE>"
    credentials_file              = "<PATH_TO_GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE>"
    #gcp_login_accounts           = ["<GCP_ACCOUNT_1>", <GCP_ACCOUNT_2>, <GCP_ACCOUNT_3>]
    username                      = tfadmin
    ```

    Uncomment the `gce_vm_service_account` if you want to login to your cluster
    using the Google email account that is associated with your GCP Project. You
    can add multiple GCP accounts to enable access to multiple users.

    An example of these configuration looks like this below:

    ```sh
    project_id                     = "anthos-bm-example1"
    region                         = "us-central1"
    zone                           = "us-central1-a"
    credentials_file               = "/usr/home/keyfiles/anthos-bm-owner.json"
    gcp_login_accounts             = ["alex@gmail.com"]
    username                       = tfadmin
    ```

1. Rename the `variables` file to the default name used by Terraform:
    > **Note:** You can skip this step if you run `terraform apply` with the `-var-file` flag

    ```sh
    mv terraform.tfvars.sample terraform.tfvars
    ```

1. Initialize the Terraform against the script ([main.tf](/anthos-bm-apigee/main.tf))
   for this sample:

    ```sh
    terraform init
    ```

1. Create a _Terraform_ execution plan:

    ```sh
    terraform plan
    ```

1. Apply the changes described in the _Terraform_ script:

    ```sh
    terraform apply
    ```

    > **Note:** When prompted to confirm the Terraform plan, type 'Yes' and enter

***The `apply` command sets up the Compute Engine VM based bare metal infrastructure. This can take a few minutes (approx. 3-5 mins) for the entire bare-metal cluster to be setup.***

---
### Deploy an Anthos cluster and Install Apigee

After the Terraform execution completes you are ready to deploy an Anthos on
bare metal cluster into the provisioned VMs.

1. SSH into the admin host _(you can this command printed as part of the Terraform output)_

    ```sh
    gcloud compute ssh tfadmin@apigee-cluster-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
    ```

2. Install the Anthos on bare metal cluster and then **install Apigee into the cluster**

    ```sh
    sudo ./run_initialization_checks.sh && \
    sudo bmctl create config -c apigee-cluster && \
    sudo cp ~/apigee-cluster.yaml bmctl-workspace/apigee-cluster && \
    sudo bmctl create cluster -c apigee-cluster && \
    ./install_apigee.sh
    ```
---

Running the commands from the Terraform output starts setting up a new Anthos
cluster. This includes checking the initialization state of the nodes, creating
the admin and user clusters and also registering the cluster with Google Cloud
using [Connect](https://cloud.google.com/anthos/multicluster-management/connect/overview).
Once, the cluster has been created successfully, the [install_apigee.sh](../resources/install_apigee.sh)
script will trigger the Apigee installation. The whole setup can take up to 30
minutes. You see the following output as the cluster is being created:

> **Note:** The logs for checks on node initialization has been left out.
> They appear before the following logs from Anthos setup

```sh
...
Waiting for cluster to become ready OK
Writing kubeconfig file
kubeconfig of created cluster is at bmctl-workspace/apigee-cluster/apigee-cluster-kubeconfig, please run
kubectl --kubeconfig bmctl-workspace/apigee-cluster/apigee-cluster-kubeconfig get nodes
to get cluster node status.
Please restrict access to this file as it contains authentication credentials of your cluster.
Waiting for node pools to become ready OK
Moving admin cluster resources to the created admin cluster
Flushing logs... OK
Deleting bootstrap cluster... OK
...
...
Operation "operations/acat.p2-739559844142-7d29aafc-49d2-47c6-9dd4-4342352c04bd" finished successfully.
Operation "operations/acat.p2-739559844142-79d3808d-6a03-4cbf-ba17-6e8208ecd321" finished successfully.
...
- Processing resources for Istio core.
✔ Istio core installed
- Processing resources for Istiod.
- Processing resources for Istiod. Waiting for Deployment/istio-system/istiod-asm-1106-2
✔ Istiod installed
...
apigeectl_1.7.0-390442d_linux_64/templates/3_apigee-environments.yaml
apigeectl_1.7.0-390442d_linux_64/templates/4_apigee-telemetries.yaml
apigeectl_1.7.0-390442d_linux_64/templates/virtualhosts.yaml
apigeectl_1.7.0-390442d_linux_64/tools/apigee-pull-push.sh
apigeectl_1.7.0-390442d_linux_64/tools/common.sh
apigeectl_1.7.0-390442d_linux_64/tools/create-service-account
apigeectl_1.7.0-390442d_linux_64/tools/dump_kubernetes.sh
apigeectl_1.7.0-390442d_linux_64/apigeectl
/home/tfadmin/apigee_workspace/apigeectl
...
...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Checking Apigee Containers ...
Apigee is Ready
Anthos on bare metal installation complete!
Run [export KUBECONFIG=/home/tfadmin/bmctl-workspace/apigee-cluster/apigee-cluster-kubeconfig] to set the kubeconfig
Run the [/home/tfadmin/login.sh] script to generate a token that you can use to login to the cluster from the Google Cloud Console
```

---
### Verify Apigee Installation

You can find your cluster's `kubeconfig` file on the admin machine in the
`bmctl-workspace` directory. To verify your deployment, complete the following
steps.

1. SSH into the admin host _(if you are not already inside it)_:

    ```sh
    # You can copy the command from the output of Terraform run from the previous step
    gcloud compute ssh tfadmin@apigee-cluster-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>
    ```

1. Set the `KUBECONFIG` environment variable to run `kubectl` commands on the
   cluster.

    ```sh
    export CLUSTER_ID=apigee-cluster
    export KUBECONFIG=$HOME/bmctl-workspace/$CLUSTER_ID/$CLUSTER_ID-kubeconfig
    kubectl get nodes
    ```

    You should see the nodes of the cluster printed, _similar_ to the output below:

    ```sh
    NAME          STATUS   ROLES    AGE   VERSION
    apigee-cluster-abm-cp1-001   Ready    master   17m   v1.18.6-gke.6600
    apigee-cluster-abm-w1-001    Ready    <none>   14m   v1.18.6-gke.6600
    apigee-cluster-abm-w2-001    Ready    <none>   14m   v1.18.6-gke.6600
    apigee-cluster-abm-w3-001    Ready    <none>   14m   v1.18.6-gke.6600
    ```

1. You can get the istio ingress gateway IP by running the following command:

    ```sh
    kubectl get svc -n istio-systems
    ```
    ```sh
    NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                      AGE
    istio-ingressgateway   LoadBalancer   172.26.232.85    10.200.0.51   15021:30217/TCP,80:32733/TCP,443:32307/TCP   13m
    istiod                 ClusterIP      172.26.232.33    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        13m
    istiod-asm-1129-3      ClusterIP      172.26.232.186   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        13m
    ```

    `EXTERNAL_IP` of istio-ingressgateway is the endpoint for API proxies
    deployed on Apigee. For example, if a mockservice with resource path of
    `/mockservice` is deployed on Apigee, it can be accessed via
    https://$EXTERNAL_IP.nip.io/mockservice

---
### Access with UI via the GCP console

During the setup process, an Apigee Organization is created and you can access
the [Apigee UI](https://cloud.google.com/apigee/docs/api-platform/fundamentals/ui-overview)
by logging [here](https://apigee.google.com) with your GCP Credentials.

---
### Cleanup

#### 1. Cleanup resources. You can cleanup the cluster setup in two ways: <!-- omit in toc -->

- (1) Delete the entire Google Cloud project [from the console]((https://console.cloud.google.com/cloud-resource-manager))

- (2) Using Terraform
  - First deregister the cluster before deleting all the resources created by Terraform

    ```sh
    # SSH into the admin host
    gcloud compute ssh tfadmin@apigee-cluster-abm-ws0-001 --project=<YOUR_PROJECT> --zone=<YOUR_ZONE>

    # Reset the cluster
    export CLUSTER_ID=apigee-cluster
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

#### 2. Delete Apigee Organization <!-- omit in toc -->

  ```sh
  gcloud alpha apigee organizations delete <YOUR_PROJECT>
  ```

#### 3. Clean Temporary files <!-- omit in toc -->

```sh
rm -fr ./resources/.temp
rm -fr terraform.tfstate
```
