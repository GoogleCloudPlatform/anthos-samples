# Attach an AKS cluster using Terraform

## Prerequisites
The sample assumes the availability of ambient credentials, which are the default credentials
automatically provided in the environment where you run the Terraform scripts. For instructions
on authenticating to Azure, see the
[Terraform documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
on the topic.
1. Ensure the latest version of the Azure CLI is [installed](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  and logged in

## Usage

1. Edit the values in the terraform.tfvars file to suit your needs. Descriptions for each variable
  can be found in `variables.tf`. Additional optional features are also available and commented out
  in the `google_container_attached_cluster` resource in `main.tf`.

    If you modify the cluster creation, ensure it meets
  [Cluster Prerequisites](https://cloud.google.com/anthos/clusters/docs/multi-cloud/attached/aks/reference/cluster-prerequisites).
1. Initialize Terraform:
    ```bash
    terraform init
    ```
1. Create and apply the plan:
    ```bash
    terraform apply
    ```
1. The process should take about 10 minutes to complete.
1. Login to the cluster:
    ```bash
    gcloud container attached clusters get-credentials CLUSTER_NAME
    ```
    This will allow you to access the cluster using kubectl, if appropriate RBAC permissions have
  been applied. For more information, see [Connect to your AKS Cluster](https://cloud.google.com/anthos/clusters/docs/multi-cloud/attached/aks/how-to/connect-to-cluster).

