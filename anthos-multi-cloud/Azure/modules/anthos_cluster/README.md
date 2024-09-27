<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_users | admin users | `list(string)` | n/a | yes |
| anthos\_prefix | anthos prefix | `string` | n/a | yes |
| application\_id | appplication id | `string` | n/a | yes |
| azure\_region | azure region | `string` | n/a | yes |
| cluster\_version | cluster version | `string` | n/a | yes |
| control\_plane\_instance\_type | control plane instance type | `string` | n/a | yes |
| fleet\_project | fleet project | `string` | n/a | yes |
| location | GCP location | `string` | n/a | yes |
| node\_pool\_instance\_type | node pool instance type | `string` | n/a | yes |
| pod\_address\_cidr\_blocks | pod address cidr blocks | `list(string)` | <pre>[<br>  "10.200.0.0/16"<br>]</pre> | no |
| resource\_group\_id | resource group id | `string` | n/a | yes |
| service\_address\_cidr\_blocks | service address cidr blocks | `list(string)` | <pre>[<br>  "10.32.0.0/24"<br>]</pre> | no |
| ssh\_public\_key | ssh public key | `string` | n/a | yes |
| subnet\_id | subnet id | `string` | n/a | yes |
| tenant\_id | tenant id | `string` | n/a | yes |
| virtual\_network\_id | virtual network id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| fleet\_membership | fleet membership |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
