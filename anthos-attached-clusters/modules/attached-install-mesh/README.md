# Attached Install Mesh

Sample module to install [Google Cloud Service Mesh](https://cloud.google.com/products/service-mesh) on [GKE Attached Clusters](https://cloud.google.com/kubernetes-engine/multi-cloud/docs/attached).

## Example usage

```
module "install-mesh" {
  source = "./attached-install-mesh"

  kubeconfig = kind_cluster.cluster.kubeconfig_path
  context    = local.cluster_context
  fleet_id   = data.google_project.project.project_id
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_service\_account | Set to false to skip running `gcloud auth activate-service-account`. Optional. | `bool` | `true` | no |
| asmcli\_download\_url | Custom asmcli download url. Optional. | `string` | `null` | no |
| asmcli\_version | The asmcli version to download. Optional. | `string` | `"1.22"` | no |
| context | The cluster contex. | `string` | n/a | yes |
| fleet\_id | The fleet\_id. | `string` | n/a | yes |
| gcloud\_download\_url | Custom gcloud download url. Optional. | `string` | `null` | no |
| gcloud\_sdk\_version | The gcloud sdk version to download. Optional. | `string` | `"491.0.0"` | no |
| jq\_download\_url | Custom jq download url. Optional. | `string` | `null` | no |
| jq\_version | The jq version to download. Optional. | `string` | `"1.6"` | no |
| kubeconfig | The kubeconfig path. | `string` | n/a | yes |
| platform | Platform asmcli will run on. Valid values: linux [default], darwin. Optional. | `string` | `"linux"` | no |
| service\_account\_key\_file | Path to service account key file to run `gcloud auth activate-service-account` with. Optional. | `string` | `""` | no |
| use\_tf\_google\_credentials\_env\_var | Use `GOOGLE_CREDENTIALS` environment variable to run `gcloud auth activate-service-account` with. Optional. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| wait | An output to use when you want to depend on cmd finishing |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
