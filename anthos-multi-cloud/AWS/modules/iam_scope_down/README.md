# Scope down resource access in IAM policies

This module showcases how to restrict access of roles assumed by `Anthos Multi-Cloud API service agent`, `cluster control plane` and `cluster node pool` based on *resource name prefix* and *AWS tags*.

## How to use this module

### Prepare a tag key-value pair for resources in your cluster.
Let's name it `access_control_tag_key` and `access_control_tag_value` as an example.

### Replace the `iam` module in anthos-samples/anthos-multi-cloud/AWS/main.tf
Use the tag key-value pair when calling the `iam_scope_down` module.
```
module "iam" {
  source                   = "./modules/iam_scope_down"
  ...
  access_control_tag_key   = local.access_control_tag_key
  access_control_tag_value = local.access_control_tag_value
}
```

### Create your cluster and node pool with the tag key-value pair
* Create two new variable in modules/anthos-cluster/variables.tf
  ```
  variable "access_control_tag_key" {
    type = string
  }
  variable "access_control_tag_value" {
    type = string
  }
  ```
* Add the variables to the tags of your cluster and node pool
  ```
  resource "google_container_aws_cluster" "this" {
    ...
    control_plane {
      ...
      tags = {
        ...
        "${var.access_control_tag_key}" : var.access_control_tag_value
      }
    }
  }

  resource "google_container_aws_node_pool" "this" {
    ...
    config {
      ...
      tags = {
        ...
        "${var.access_control_tag_key}" : var.access_control_tag_value
      }
    }
  }
  ```
* Pass the tag key-value pair to your `anthos-cluster` module in anthos-multi-cloud/AWS/main.tf
  ```
  module "anthos_cluster" {
    ...
    access_control_tag_key   = local.access_control_tag_key
    access_control_tag_value = local.access_control_tag_value
  }
  ```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_control\_tag\_key | The tag key that applies to IAM role policies to control access to AWS resources | `string` | n/a | yes |
| access\_control\_tag\_value | The tag value that applies to IAM role policies to control access to AWS resources | `string` | n/a | yes |
| anthos\_prefix | Prefix to apply to Anthos AWS Policy & Network names | `string` | n/a | yes |
| cp\_config\_kms\_arn | Control Plane Configuration KMS ARN | `string` | n/a | yes |
| cp\_main\_volume\_kms\_arn | Control Plane Main Volume KMS ARN | `string` | n/a | yes |
| db\_kms\_arn | DB KMS ARN | `string` | n/a | yes |
| gcp\_project\_number | GCP project Number of project to host cluster | `string` | n/a | yes |
| np\_config\_kms\_arn | Node Pool Configuration KMS ARN | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| api\_role\_arn | ARN of the actuated IAM role resource |
| cp\_instance\_profile\_id | IAM instance profile of controlplane |
| np\_instance\_profile\_id | IAM instance profile of nodepool |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
