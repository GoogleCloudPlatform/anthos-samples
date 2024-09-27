<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_users | admin users | `list(string)` | n/a | yes |
| anthos\_prefix | anthos prefix | `string` | n/a | yes |
| aws\_region | aws region | `string` | n/a | yes |
| cluster\_version | cluster version | `string` | n/a | yes |
| control\_plane\_config\_encryption\_kms\_key\_arn | control plane config encryption kms key arn | `string` | n/a | yes |
| control\_plane\_iam\_instance\_profile | control plane iam instance profile | `string` | n/a | yes |
| control\_plane\_instance\_type | control plane instance type | `string` | n/a | yes |
| control\_plane\_main\_volume\_encryption\_kms\_key\_arn | control plane main volume encryption kms key arn | `string` | n/a | yes |
| control\_plane\_root\_volume\_encryption\_kms\_key\_arn | control plane root volume encryption kme key arn | `string` | n/a | yes |
| database\_encryption\_kms\_key\_arn | database encruption kms key arn | `string` | n/a | yes |
| fleet\_project | flet project | `string` | n/a | yes |
| location | GCP location | `string` | n/a | yes |
| node\_pool\_config\_encryption\_kms\_key\_arn | node pool config encruyption kms key arn | `string` | n/a | yes |
| node\_pool\_iam\_instance\_profile | node pool iam instance profile | `string` | n/a | yes |
| node\_pool\_instance\_type | node pool instance type | `string` | n/a | yes |
| node\_pool\_root\_volume\_encryption\_kms\_key\_arn | node pool root volume encruption kms key arn | `string` | n/a | yes |
| node\_pool\_subnet\_id | node pool subnet id | `string` | n/a | yes |
| pod\_address\_cidr\_blocks | pod address cider blocks | `list(string)` | <pre>[<br>  "10.2.0.0/16"<br>]</pre> | no |
| role\_arn | role arn | `string` | n/a | yes |
| service\_address\_cidr\_blocks | service address cidr blocks | `list(string)` | <pre>[<br>  "10.1.0.0/16"<br>]</pre> | no |
| subnet\_ids | subnet ids | `list(string)` | n/a | yes |
| vpc\_id | VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| fleet\_membership | fleet membership |
| project\_number | project number |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
