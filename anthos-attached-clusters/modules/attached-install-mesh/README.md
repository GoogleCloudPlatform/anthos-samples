# Attached Install Mesh

Sample module to install [Google Cloud Service Mesh](https://cloud.google.com/products/service-mesh) on [GKE Attached Clusters](https://cloud.google.com/kubernetes-engine/multi-cloud/docs/attached).

## Example usage

```
module "install-mesh" {
  source = "github.com/GoogleCloudPlatform/anthos-samples.git//anthos-attached-clusters/modules/attached-install-mesh?ref=3bde26802919539d27ae9295a8b936d7aa827eb3" #TODO: Use ref= release tag e.g. v0.15.4

  kubeconfig = "PATH TO CLUSTER CONTEXT FILE"
  context    = "CLUSTER CONTEXT"
  fleet_id   = "FLEET PROJECT ID"

  asmcli_enable_cluster_roles      = true
  asmcli_enable_cluster_labels     = true
  asmcli_enable_gcp_components     = true
  asmcli_enable_namespace_creation = true
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_service\_account | Set to false to skip running `gcloud auth activate-service-account`. Optional. | `bool` | `true` | no |
| asmcli\_additional\_arguments | asmcli: additional arguments | `string` | `null` | no |
| asmcli\_ca | asmcli: certificate authority | `string` | `"mesh_ca"` | no |
| asmcli\_download\_url | Custom asmcli download url. Optional. | `string` | `null` | no |
| asmcli\_enable\_all | asmcli: enable all | `bool` | `false` | no |
| asmcli\_enable\_cluster\_labels | asmcli: enable cluster labels | `bool` | `false` | no |
| asmcli\_enable\_cluster\_roles | asmcli: enable cluster roles | `bool` | `false` | no |
| asmcli\_enable\_gcp\_apis | asmcli: enable gcp apis | `bool` | `false` | no |
| asmcli\_enable\_gcp\_components | asmcli: enable gcp components | `bool` | `false` | no |
| asmcli\_enable\_gcp\_iam\_roles | asmcli: enable gcp iam roles | `bool` | `false` | no |
| asmcli\_enable\_meshconfig\_init | asmcli: enable meshconfig init | `bool` | `false` | no |
| asmcli\_enable\_namespace\_creation | asmcli: enable namespace creation | `bool` | `false` | no |
| asmcli\_enable\_registration | asmcli: enable registration | `bool` | `false` | no |
| asmcli\_verbose | asmcli: verbose | `bool` | `false` | no |
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
