## Install ABM Module

This module triggers the Anthos on bare metal installation script from inside
the provided GCE VM via SSH.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| publicIp | Publicly accessible IP address of the Admin VM | `string` | n/a | yes |
| ssh\_private\_key\_file | Path to private key to use when SSH'ing into the admin VM | `string` | n/a | yes |
| username | The name of the user who should run the install scripts | `string` | `"tfadmin"` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
