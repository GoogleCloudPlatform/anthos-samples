<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| anthos\_prefix | anthos name prefix | `string` | n/a | yes |
| aws\_region | AWS Region to use for KMS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| control\_plane\_config\_encryption\_kms\_key\_arn | ARN of the actuated KMS key resource for cluster control plane user data encryption |
| control\_plane\_main\_volume\_encryption\_kms\_key\_arn | ARN of the actuated KMS key resource for cluster control plane main volume encryption |
| control\_plane\_root\_volume\_encryption\_kms\_key\_arn | ARN of the actuated KMS key resource for cluster control plane root volume encryption |
| database\_encryption\_kms\_key\_arn | ARN of the actuated KMS key resource for cluster secret encryption |
| node\_pool\_config\_encryption\_kms\_key\_arn | ARN of the actuated KMS key resource for cluster node pool user data encryption |
| node\_pool\_root\_volume\_encryption\_kms\_key\_arn | ARN of the actuated KMS key resource for cluster node pool root volume encryption |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
