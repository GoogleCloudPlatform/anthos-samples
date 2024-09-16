## Terraform Variables

The following information is generated using the
[`terraform-docs`](https://github.com/terraform-docs/terraform-docs)
CLI tool. Use the commands below to re-generate this information during a
release or when you update the variables file.

```sh
export VARIABLES_TF_FILE=<PATH_TO_THE_VARIABLES_FILE_FOR_MODULE>
export VARIABLES_MD_FILE=<PATH_TO_THE_VARIABLES_MARKDOWN_FILE>
export TF_DOCS_CONFIG=<ROOT_OF_REPO>/.github/terraform-docs/main.yaml

terraform-docs markdown table \
    --config ${TF_DOCS_CONFIG} \
    --output-file ${VARIABLES_MD_FILE} \
    --output-mode inject \
    ${VARIABLES_TF_FILE}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | 1.47.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | 1.47.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_vm_hosts"></a> [admin\_vm\_hosts](#module\_admin\_vm\_hosts) | ./modules/vm | n/a |
| <a name="module_cp_vm_hosts"></a> [cp\_vm\_hosts](#module\_cp\_vm\_hosts) | ./modules/vm | n/a |
| <a name="module_worker_vm_hosts"></a> [worker\_vm\_hosts](#module\_worker\_vm\_hosts) | ./modules/vm | n/a |

## Resources

| Name | Type |
|------|------|
| [openstack_compute_floatingip_associate_v2.abm_ws_ip_lb_association](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/compute_floatingip_associate_v2) | resource |
| [openstack_compute_secgroup_v2.basic_access](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/compute_secgroup_v2) | resource |
| [openstack_lb_listener_v2.abm_cp_lb_listener](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/lb_listener_v2) | resource |
| [openstack_lb_loadbalancer_v2.abm_cp_lb](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/lb_loadbalancer_v2) | resource |
| [openstack_lb_member_v2.lb_membership_cp_nodes](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/lb_member_v2) | resource |
| [openstack_lb_monitor_v2.abm_cp_lb_monitor](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/lb_monitor_v2) | resource |
| [openstack_lb_pool_v2.abm_cp_lb_pool](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/lb_pool_v2) | resource |
| [openstack_networking_floatingip_associate_v2.abm_cp_ip_lb_association](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/networking_floatingip_associate_v2) | resource |
| [openstack_networking_floatingip_v2.abm_cp_floatingip](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/networking_floatingip_v2) | resource |
| [openstack_networking_floatingip_v2.abm_ws_floatingip](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/networking_floatingip_v2) | resource |
| [openstack_networking_network_v2.abm_network](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/networking_network_v2) | resource |
| [openstack_networking_router_interface_v2.abm_interface_1](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/networking_router_interface_v2) | resource |
| [openstack_networking_router_v2.abm_network_router](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/networking_router_v2) | resource |
| [openstack_networking_subnet_v2.abm_subnetwork](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/1.47.0/docs/resources/networking_subnet_v2) | resource |
| [tls_private_key.abm_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [template_file.cloud_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_network_id"></a> [external\_network\_id](#input\_external\_network\_id) | The id of the external network that is used for floating IP addresses | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The source image to use when provisioning the OpenStack VMs.<br>    Use 'openstack image list' to find a list of all available images | `string` | `"ubuntu-2004"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to provision per layer (Control plane and Worker nodes) of the cluster | `map(any)` | <pre>{<br>  "controlplane": 1,<br>  "worker": 1<br>}</pre> | no |
| <a name="input_lb_method"></a> [lb\_method](#input\_lb\_method) | The algorithm to use for load balancing requests. Valid values are<br>    ROUND\_ROBIN, LEAST\_CONNECTIONS, SOURCE\_IP, or SOURCE\_IP\_PORT | `string` | `"ROUND_ROBIN"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to use when provisioning the OpenStack VMs.<br>    Use 'openstack flavor list' to find a list of all available flavors | `string` | `"m1.jumbo"` | no |
| <a name="input_network_mtu"></a> [network\_mtu](#input\_network\_mtu) | The Maximum Transport Unit for packets over the OpenStack network | `number` | `1400` | no |
| <a name="input_os_auth_url"></a> [os\_auth\_url](#input\_os\_auth\_url) | The OpenStack authentication URL to be used by the provider | `string` | n/a | yes |
| <a name="input_os_endpoint_type"></a> [os\_endpoint\_type](#input\_os\_endpoint\_type) | The type of the OpenStack endpoint to use; whether its public or internal | `string` | `"internalURL"` | no |
| <a name="input_os_password"></a> [os\_password](#input\_os\_password) | The password to be used to authenticate the OpenStack provider client | `string` | n/a | yes |
| <a name="input_os_region"></a> [os\_region](#input\_os\_region) | The OpenStack region in which the VMs are to be provisioned | `string` | `"RegionOne"` | no |
| <a name="input_os_tenant_name"></a> [os\_tenant\_name](#input\_os\_tenant\_name) | The OpenStack tenant information for the current setup | `string` | `"admin"` | no |
| <a name="input_os_user_name"></a> [os\_user\_name](#input\_os\_user\_name) | The username to be used to authenticate the OpenStack provider client | `string` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | The name of the SSH key pair to associate with the provisioned OpenStack VMs.<br>    Use 'openstack key list' to find a list of all available keys | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_ws_public_ip"></a> [admin\_ws\_public\_ip](#output\_admin\_ws\_public\_ip) | Public IP address of the admin workstation VM in the Openstack deployment |
<!-- END_TF_DOCS -->
