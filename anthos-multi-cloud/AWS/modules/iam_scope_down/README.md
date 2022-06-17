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
