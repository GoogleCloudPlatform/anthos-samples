## External-IP Module

This module creates a Google Cloud External IP using the [`google_compute_address`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) resource in the [Google Terraform provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ip\_names | List of names to be used to name the IP addresses | `list(string)` | n/a | yes |
| is\_global | Indication of whether the IP address must be global | `bool` | `false` | no |
| region | Region where the IP addresses are to be created in | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ips | IP information of all the VMs that were created. It is in the form of a map<br>    which has the VM hostname as the key and an object as the value. The details<br>    in the object differs based on the type of the IP address.<br>      Global IP address: [id, ip\_address]<br>      Regional IP address: [id, ip\_address, tier, region] |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
