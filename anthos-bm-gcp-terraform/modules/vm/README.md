## GCE VM Module

This module creates a Google Compute Engine VMs using the [`compute_instance`](https://registry.terraform.io/modules/terraform-google-modules/vm/google/latest/submodules/compute_instance) submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance\_template | Google Cloud instance template based on which the VMs are to be provisioned | `string` | n/a | yes |
| network | VPC network to which the provisioned VMs are to be connected to | `string` | `"default"` | no |
| region | Google Cloud Region in which the External IP addresses should be provisioned | `string` | `"us-central1"` | no |
| vm\_names | List of names to be given to the Compute Engine VMs that are provisioned | `list(any)` | n/a | yes |
| zone | Google Cloud Zone in which the VMs should be provisioned | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm\_info | Information pertaining to all the VMs that were created. It is in the form<br>    of a list of objects. Each object contains the hostname, internal IP address<br>    and the external IP address of a specific VM that was created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
