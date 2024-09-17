## GCE VM Module

This module creates a Google Compute Engine VMs using the [`compute_instance`](https://registry.terraform.io/modules/terraform-google-modules/vm/google/latest/submodules/compute_instance) submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| flavor | The machine type to use when provisioning the OpenStack VMs.<br>    Use 'openstack flavor list' to find a list of all available flavors | `string` | `"m1.xlarge"` | no |
| image | The source image to use when provisioning the OpenStack VMs.<br>    Use 'openstack image list' to find a list of all available images | `string` | `"ubuntu-1804"` | no |
| key | The key pair to associate with the provisioned the OpenStack VMs.<br>    Use 'openstack key list' to find a list of all available flavors | `string` | `"abm_key"` | no |
| network | The OpenStack network to which the VM is to be attached to. | `string` | n/a | yes |
| security\_groups | The security groups to which the provisioned OpenStack VMs are to be<br>    associated to. | `list(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| user\_data | The user data to be provided to the cloud-init system on the provisioned<br>    VMs. This will be used to setup the VM on first boot. | `string` | `""` | no |
| vm\_info | List of names to be given to the OpenStack VMs that are provisioned | `list(object({ name = string, ip = string }))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vm\_ids | Output the list of IDs of the OpenStack VMs created by this module |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
