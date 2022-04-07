## GCE VM Module

This module creates a Google Compute Engine VMs using the [`compute_instance`](https://registry.terraform.io/modules/terraform-google-modules/vm/google/latest/submodules/compute_instance) submodule.

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
| [openstack_compute_instance_v2.openstack_instance](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/compute_instance_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_flavor"></a> [flavor](#input\_flavor) | The machine type to use when provisioning the OpenStack VMs.<br>    Use 'openstack flavor list' to find a list of all available flavors | `string` | `"m1.xlarge"` | no |
| <a name="input_image"></a> [image](#input\_image) | The source image to use when provisioning the OpenStack VMs.<br>    Use 'openstack image list' to find a list of all available images | `string` | `"ubuntu-1804"` | no |
| <a name="input_key"></a> [key](#input\_key) | The key pair to associate with the provisioned the OpenStack VMs.<br>    Use 'openstack key list' to find a list of all available flavors | `string` | `"abm_key"` | no |
| <a name="input_network"></a> [network](#input\_network) | The OpenStack network to which the VM is to be attached to. | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The security groups to which the provisioned OpenStack VMs are to be<br>    associated to. | `list(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to be provided to the cloud-init system on the provisioned<br>    VMs. This will be used to setup the VM on first boot. | `string` | `""` | no |
| <a name="input_vm_info"></a> [vm\_info](#input\_vm\_info) | List of names to be given to the OpenStack VMs that are provisioned | `list(object({ name = string, ip = string }))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_ids"></a> [vm\_ids](#output\_vm\_ids) | Output the list of IDs of the OpenStack VMs created by this module |
<!-- END_TF_DOCS -->
