# Install GKE on Azure using Terraform

This script is meant to be a quick start to working with Anthos on Azure. For more information on Anthos Multi-Cloud please [click here](https://cloud.google.com/anthos/clusters/docs/multi-cloud/). This terraform script will install all relevant IaaS in Azure _(VNet, App Registration, Resource Groups, KMS)_.

![Anthos Multi-Cloud](Anthos-Multi-Azure.png)

 **The Terraform script deploys Anthos GKE with:**
- 3 control plane nodes _(1 in each AZ)_ of type [Standard_B2s](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable)
- A single node pool of type Standard_B2s with 1 node in an autoscaling group to max 3 nodes to the `Azure East US` region.

**Other information:**
- Supported instance types in Azure can be found [here](https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/reference/supported-vms).
- You can adjust the region and AZs in the [variables.tf](/anthos-multi-cloud/Azure/variables.tf) file.
- For a list of Azure regions and associated K8s version supported per GCP region please use the following command:
```bash
gcloud alpha container azure get-server-config --location [gcp-region]
```
After the cluster has been installed it will show up in the [Kubernetes Engine page](https://console.cloud.google.com/kubernetes/list/overview) of the GCP console in your relevant GCP project.

## Prerequisites

1. Ensure you have gCloud SDK 365.0.1 or greater [installed](https://cloud.google.com/sdk/docs/install)
   ```
   gcloud components update
   ```

1. Download the `az` CLI utility. Ensure it is in your `$PATH`.

   ```bash
   curl -L https://aka.ms/InstallAzureCli | bash
   ```

1. Log in to your Azure account and get account details.

   ```bash
   az login
   ```

1. Set the following variables for Azure Terraform authentication. The example uses [Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) way of authenticating Terraform.

   ```bash
   export ARM_SUBSCRIPTION_ID=$(az account show --query "id" --output tsv)
   export ARM_TENANT_ID=$(az account list --query "[?id=='${ARM_SUBSCRIPTION_ID}'].{tenantId:tenantId}" --output tsv)

   echo -e "ARM_SUBSCRIPTION_ID is ${ARM_SUBSCRIPTION_ID}"
   echo -e "ARM_TENANT_ID is ${ARM_TENANT_ID}"
   ```

   Ouput looks like the following

   ```
   ARM_SUBSCRIPTION_ID is abcdef123-abcd-1234-aaaa-12345abcdef
   ARM_TENANT_ID is 1230982dfd-123a-1234-7a54-12345abcdef
   ```

## Prepare Terraform

1. Configure GCP Terraform authentication.

   ```bash
   echo PROJECT_ID=Your GCP Project ID

   gcloud config set project "${PROJECT_ID}"
   gcloud auth application-default login --no-launch-browser
   ```

1. Enable services in your GCP project.

   ```bash
   gcloud --project="${PROJECT_ID}" services enable \
   gkemulticloud.googleapis.com \
   gkeconnect.googleapis.com \
   connectgateway.googleapis.com \
   cloudresourcemanager.googleapis.com \
   anthos.googleapis.com \
   logging.googleapis.com \
   monitoring.googleapis.com
   ```

1. Clone this repo and go into the Azure folder.

   ```bash
   git clone https://github.com/GoogleCloudPlatform/anthos-samples.git
   cd anthos-samples/anthos-multi-cloud/Azure
   ```

## Deploy Anthos Clusters(GKE) on Azure cluster

1. Edit the following values in the **terraform.tfvars** file. The admin user will be the GCP account email address that can login to the clusters once they are created via the connect gateway.

  ```bash
   gcp_project_id = "xxx-xxx-xxx"
   admin_user = "example@example.com"
   ```

1. Initialize and create terraform plan.

   ```bash
   terraform init
   ```

1. Apply terraform.

   ```bash
   terraform apply
   ```
    Once started the installation process will take about 12 minutes. **After the script completes you will see a var.sh file in the root directory that has varialbles for the anthos install** if you need to create more node pools manually in the future. Note manually created node pools will need to be deleted manually before you run terraform destroy

1. Authorize Cloud Logging / Cloud Monitoring

   Enable system container logging and container metrics. You can only do this after the first Anthos cluster has been created.
   ([read more](https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/how-to/create-cluster#telemetry-agent-auth))

   ``` bash
   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
   --member="serviceAccount:${PROJECT_ID}.svc.id.goog[gke-system/gke-telemetry-agent]" \
   --role=roles/gkemulticloud.telemetryWriter
   ```

 1. Login to the Cluster

   ```bash
   gcloud container hub memberships get-credentials [cluster name]
   kubectl get nodes
   ```
## Extra: Connect Anthos Configuration Management

If you would like to test out the Anthos Configuration and Policy Management feature you can visit this [quickstart](https://cloud.google.com/anthos-config-management/docs/archive/1.9/config-sync-quickstart).

## Delete Anthos on Azure Cluster

1. Run the following command to delete Anthos on Azure cluster.

   ```bash
   terraform destroy
   ```
