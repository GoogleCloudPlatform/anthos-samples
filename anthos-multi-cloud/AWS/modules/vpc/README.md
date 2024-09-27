<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| anthos\_prefix | Anthos naming prefix | `string` | n/a | yes |
| cp\_private\_subnet\_cidr\_blocks | CIDR blocks to use for control plane private subnets | `list(string)` | `[]` | no |
| public\_subnet\_cidr\_block | CIDR blcok to use for public subnet | `list(string)` | `[]` | no |
| subnet\_availability\_zones | Availability zones to create subnets in | `list(string)` | `[]` | no |
| vpc\_cidr\_block | CIDR block to use for VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cp\_subnet\_id\_1 | private subnet ID of control plane 1 |
| aws\_cp\_subnet\_id\_2 | private subnet ID of control plane 2 |
| aws\_cp\_subnet\_id\_3 | private subnet ID of control plane 3 |
| aws\_vpc\_id | ARN of the actuated KMS key resource for cluster secret encryption |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
