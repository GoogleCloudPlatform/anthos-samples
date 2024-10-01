<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aad\_app\_name | app registration name | `string` | n/a | yes |
| name | Name for the test cluster | `string` | n/a | yes |
| region | Azure region to deploy to | `string` | n/a | yes |
| sp\_obj\_id | app service principal object id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| location | The location/region of vnet |
| subnet\_address\_prefixes | The address prefixes of the subnet |
| subnet\_id | The ID of the subnet |
| vnet\_id | The ID of the vnet |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
