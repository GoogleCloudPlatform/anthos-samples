<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name for the test cluster | `string` | n/a | yes |
| region | Azure region to deploy to | `string` | n/a | yes |
| sp\_obj\_id | app service principal object id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| resource\_group\_id | The id of the cluster resource group |
| tenant\_id | azure tenant id |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
