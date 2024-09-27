<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application\_name | Name of the Azure application to create: ex: GCP-Anthos | `string` | n/a | yes |
| project\_number | GCP project number of project to host cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aad\_app\_id | The id of the aad app registration |
| aad\_app\_obj\_id | The object id of the aad app registration |
| aad\_app\_sp\_obj\_id | The object id of the aad service principal |
| subscription\_id | The ID of the subscription |
| tenant\_id | The ID of the tenant |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
