## Initialize VMs Module

This module copies the required configuration files and scripts _(from the [resources](/anthos-bm-gcp-terraform/resources) directory)_ into the GCE VMs and runs the
initialization steps.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcloud_add_ssh_key_metadata"></a> [gcloud\_add\_ssh\_key\_metadata](#module\_gcloud\_add\_ssh\_key\_metadata) | terraform-google-modules/gcloud/google | 3.1.1 |

## Resources

| Name | Type |
|------|------|
| [local_file.temp_ssh_priv_key_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.temp_ssh_pub_key_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.exec_init_script](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.ssh_key_pair](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_yaml_path"></a> [cluster\_yaml\_path](#input\_cluster\_yaml\_path) | Path to the YAML configuration file describing the Anthos cluster | `string` | `"../../resources/.cluster1.yaml"` | no |
| <a name="input_credentials_file"></a> [credentials\_file](#input\_credentials\_file) | Path to the Google Cloud Service Account key file.<br>    This is the key that will be used to authenticate the provider with the Cloud APIs | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname of the target VM | `string` | n/a | yes |
| <a name="input_init_check_script"></a> [init\_check\_script](#input\_init\_check\_script) | Path to the script that validates if the initialization is complete | `string` | `"../../resources/run_initialization_checks.sh"` | no |
| <a name="input_init_logs"></a> [init\_logs](#input\_init\_logs) | Name of the file to write the logs of the initialization script | `string` | `"init.log"` | no |
| <a name="input_init_script"></a> [init\_script](#input\_init\_script) | Path to the initilization script that is to be run on the target VM | `string` | `"../../resources/init_vm.sh"` | no |
| <a name="input_init_vars_file"></a> [init\_vars\_file](#input\_init\_vars\_file) | Path to the file containing the host specific arguments to the init script | `string` | n/a | yes |
| <a name="input_install_abm_script"></a> [install\_abm\_script](#input\_install\_abm\_script) | Path to the script that installs Anthos on bare metal | `string` | `"../../resources/install_abm.sh"` | no |
| <a name="input_login_script"></a> [login\_script](#input\_login\_script) | Path to the script that generates the token used to login to the Anthos bare metal cluster | `string` | `"../../resources/login.sh"` | no |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | List of modules or resources this module depends on. | `list(any)` | `[]` | no |
| <a name="input_nfs_yaml_path"></a> [nfs\_yaml\_path](#input\_nfs\_yaml\_path) | Path to the NFS YAML configuration file for the Anthos cluster | `string` | `"../../resources/.nfs-csi.yaml"` | no |
| <a name="input_priv_key_path_template"></a> [priv\_key\_path\_template](#input\_priv\_key\_path\_template) | Template denoting the path where the private key is to be stored | `string` | `"../../resources/.ssh-key-%s.priv"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Google Cloud Project where the target resources live | `string` | n/a | yes |
| <a name="input_pub_key_path_template"></a> [pub\_key\_path\_template](#input\_pub\_key\_path\_template) | Template denoting the path where the public key is to be stored | `string` | `"../../resources/.ssh-key-%s.pub"` | no |
| <a name="input_publicIp"></a> [publicIp](#input\_publicIp) | Publicly accessible IP address of the target VM | `string` | n/a | yes |
| <a name="input_resources_path"></a> [resources\_path](#input\_resources\_path) | Path to the resources folder with the template files | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | The name of the user to be created to execute the init script | `string` | `"tfadmin"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Google Cloud Zone where the target VM is in | `string` | `"us-central1-a"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
