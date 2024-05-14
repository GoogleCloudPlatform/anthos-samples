# Sandbox Example to Attach a [kind](https://kind.sigs.k8s.io/) Cluster using Terraform

## Prerequisites
The sample is meant just to provide a local example for experimentation. It assumes an environment where [`kind`](https://kind.sigs.k8s.io/) is available and could otherwise be run on the command line, e.g. `kind create cluster`.

## A note on providers

The other examples and module limit dependanices to terraform core providers, but this example takes advantage of some community supplied [providers](provider.tf). They're widely used for their purpose, but please review and consider.

## Usage

1. Edit the values in the terraform.tfvars file to suit your needs. Descriptions for each variable
  can be found in `variables.tf`. Additional optional features are also available and commented out
  in the `google_container_attached_cluster` resource in `main.tf`.

    If you modify the cluster creation, ensure it meets
  [Cluster Prerequisites](https://cloud.google.com/anthos/clusters/docs/multi-cloud/attached/eks/reference/cluster-prerequisites).
1. Initialize Terraform:
    ```bash
    terraform init
    ```
1. Create and apply the plan:
    ```bash
    terraform apply
    ```
    Terraform may give a warning along the lines of `Warning: Content-Type is not recognized as a text type, got "application/jwk-set+json"` but this is ok and just a side effect of the `http` provider we're using and the content type the cluster returns for the `jwks` content.
1. The process should take about a few short minutes to complete.
1. Login to the cluster:
    ```bash
    gcloud container attached clusters get-credentials CLUSTER_NAME
    ```
    This will allow you to access the cluster using kubectl as you would other GKE Enterprise clusters, regardless of location (ie in GCP, other clouds, or on prem).



