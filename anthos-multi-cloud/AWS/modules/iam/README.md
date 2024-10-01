<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
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
