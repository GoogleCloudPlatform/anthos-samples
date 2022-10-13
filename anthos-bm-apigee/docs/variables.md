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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v0.15.5, < 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.68.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 3.68.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_install_abm_on_gce"></a> [install\_abm\_on\_gce](#module\_install\_abm\_on\_gce) | ../anthos-bm-gcp-terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_credentials_file"></a> [credentials\_file](#input\_credentials\_file) | Path to the Google Cloud Service Account key file.<br>    This is the key that will be used to authenticate the provider with the Cloud APIs | `string` | n/a | yes |
| <a name="input_gce_vm_service_account"></a> [gce\_vm\_service\_account](#input\_gce\_vm\_service\_account) | Service Account to use for GCE instances | `string` | `""` | no |
| <a name="input_gcp_login_accounts"></a> [gcp\_login\_accounts](#input\_gcp\_login\_accounts) | GCP account email addresses that must be allowed to login to the cluster using Google Cloud Identity. | `list(string)` | `[]` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | Indication of the execution mode. By default the terraform execution will end<br>    after setting up the GCE VMs where the Anthos bare metal clusters can be deployed.<br><br>    **setup:** create and initialize the GCE VMs required to install Anthos bare metal.<br><br>    **install:** everything up to 'setup' mode plus automatically run Anthos bare metal installation steps as well.<br><br>    **manuallb:** similar to 'install' mode but Anthos on bare metal is installed with ManualLB mode. | `string` | `"setup"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud Region in which the Compute Engine VMs should be provisioned | `string` | `"us-central1"` | no |
| <a name="input_username"></a> [username](#input\_username) | The name of the user to be created on each Compute Engine VM to execute the init script | `string` | `"tfadmin"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone within the selected Google Cloud Region that is to be used | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_vm_ssh"></a> [admin\_vm\_ssh](#output\_admin\_vm\_ssh) | Run the following command to provision the anthos cluster. |
| <a name="output_controlplane_ip"></a> [controlplane\_ip](#output\_controlplane\_ip) | You may access the control plane nodes of the Anthos on bare metal cluster<br>    by accessing this IP address. You need to copy the kubeconfig file for the<br>    cluster from the admin workstation to access using the kubectl CLI. |
| <a name="output_ingress_ip"></a> [ingress\_ip](#output\_ingress\_ip) | You may access the application deployed in the Anthos on bare metal cluster<br>    by accessing this IP address |
| <a name="output_installation_check"></a> [installation\_check](#output\_installation\_check) | Run the following command to check the Anthos bare metal installation status. |
<!-- END_TF_DOCS -->
