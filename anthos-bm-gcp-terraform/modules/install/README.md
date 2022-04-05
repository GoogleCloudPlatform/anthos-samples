## Install ABM Module

This module triggers the Anthos on bare metal installation script from inside
the provided GCE VM via SSH.

The following information is generated using the
[`terraform-docs`](https://github.com/terraform-docs/terraform-docs)
CLI tool. Use the commands below to re-generate this information during a
release or when you update the variables file.

```sh
export VARIABLES_TF_FILE=<PATH_TO_THE_VARIABLES_FILE_FOR_MODULE>
export VARIABLES_MD_FILE=<PATH_TO_THE_VARIABLES_MARKDOWN_FILE>
export TF_DOCS_CONFIG=<ROOT_OF_REPO>/.github/terraform-docs/module.yaml

terraform-docs markdown table \
    --config ${TF_DOCS_CONFIG} \
    --output-file ${VARIABLES_MD_FILE} \
    --output-mode inject \
    ${VARIABLES_TF_FILE}
```

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.run_abm_installation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_publicIp"></a> [publicIp](#input\_publicIp) | Publicly accessible IP address of the Admin VM | `string` | n/a | yes |
| <a name="input_ssh_private_key_file"></a> [ssh\_private\_key\_file](#input\_ssh\_private\_key\_file) | Path to private key to use when SSH'ing into the admin VM | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | The name of the user who should run the install scripts | `string` | `"tfadmin"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
