# Sandbox Example to Attach a [kind](https://kind.sigs.k8s.io/) Cluster using Terraform

## Prerequisites
The sample is meant just to provide a local example for experimentation. It assumes an environment where [`kind`](https://kind.sigs.k8s.io/) is available and could otherwise be run on the command line, e.g. `kind create cluster`.

## A note on providers

The other examples and module limit dependancies to terraform core providers, but this example takes advantage of some community supplied [providers](provider.tf). They're widely used for their purpose, but please review and consider.

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
1. Set some variables based on the terraform projects values and use them to generate RBAC for the cluster and credentials to login:
    ```bash

    PROJECT=$(terraform output PROJECT)
    CLUSTER=$(terraform output CLUSTER)
    KUBECONFIG=$(terraform output KUBECONFIG)
    CONTEXT=$(terraform output CONTEXT)

    # set this to whomever you'd like to grant access
    PRINCIPAL=update.this@example.com
    # set this whatever role you intend
    ROLE=clusterrole/cluster-admin

    gcloud container fleet memberships generate-gateway-rbac --apply \
           --kubeconfig ${KUBECONFIG} --context=${CONTEXT} \
           --project=${PROJECT} \
           --membership=${CLUSTER} \
           --role=${ROLE} \
           --users=${PRINCIPAL}

    gcloud container fleet  memberships get-credentials ${CLUSTER}  --project ${PROJECT}

    kubectl get ns

    ```
    This will allow you to access the cluster using kubectl as you would other GKE Enterprise clusters, regardless of location (ie in GCP, other clouds, or on prem).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gcp\_location | GCP location to create the attached resource in | `string` | `"us-west1"` | no |
| gcp\_project\_id | The GCP project id where the cluster will be registered | `string` | n/a | yes |
| kind\_api\_server\_address | Kind cluster API server address | `string` | `null` | no |
| kind\_api\_server\_port | Kind cluster API server port | `number` | `null` | no |
| kind\_node\_image | The image used for the kind cluster | `string` | `"kindest/node:v1.28.0"` | no |
| kubeconfig\_path | The kubeconfig path. | `string` | `null` | no |
| name\_prefix | Common prefix to use for generating names | `string` | n/a | yes |
| platform\_version | Platform version of the attached cluster resource | `string` | `"1.28.0-gke.3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| CLUSTER | cluster name |
| CONTEXT | cluster context |
| KUBECONFIG | cluster kubeconfig |
| PROJECT | cluster project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
