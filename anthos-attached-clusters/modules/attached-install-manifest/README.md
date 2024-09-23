# Attached Install Manifest

## Example usage

```
module "attached_install_manifest" {
  source                         = "./attached-install-manifest"
  attached_cluster_name          = CUSTER NAME
  attached_cluster_fleet_project = PROJECT ID
  gcp_location                   = LOCATION
  platform_version               = VERSION
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attached\_cluster\_fleet\_project | GCP fleet project ID where the cluster will be attached | `string` | n/a | yes |
| attached\_cluster\_name | Name for the attached cluster resource | `string` | n/a | yes |
| gcp\_location | GCP location to create the attached resource in | `string` | `"us-west1"` | no |
| platform\_version | Platform version of the attached cluster resource | `string` | `"1.28.8-gke.3"` | no |
| temp\_dir | Directory name to temporarily write out the helm chart for bootstrapping the attach process | `string` | `""` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
