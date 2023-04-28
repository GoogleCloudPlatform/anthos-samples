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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.36.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_vm_hosts"></a> [admin\_vm\_hosts](#module\_admin\_vm\_hosts) | ./modules/vm | n/a |
| <a name="module_configure_controlplane_lb"></a> [configure\_controlplane\_lb](#module\_configure\_controlplane\_lb) | ./modules/loadbalancer | n/a |
| <a name="module_configure_ingress_lb"></a> [configure\_ingress\_lb](#module\_configure\_ingress\_lb) | ./modules/loadbalancer | n/a |
| <a name="module_controlplane_vm_hosts"></a> [controlplane\_vm\_hosts](#module\_controlplane\_vm\_hosts) | ./modules/vm | n/a |
| <a name="module_create_service_accounts"></a> [create\_service\_accounts](#module\_create\_service\_accounts) | terraform-google-modules/service-accounts/google | ~> 4.0 |
| <a name="module_enable_google_apis_primary"></a> [enable\_google\_apis\_primary](#module\_enable\_google\_apis\_primary) | terraform-google-modules/project-factory/google//modules/project_services | 13.0.0 |
| <a name="module_enable_google_apis_secondary"></a> [enable\_google\_apis\_secondary](#module\_enable\_google\_apis\_secondary) | terraform-google-modules/project-factory/google//modules/project_services | 13.0.0 |
| <a name="module_gke_hub_membership"></a> [gke\_hub\_membership](#module\_gke\_hub\_membership) | terraform-google-modules/gcloud/google | ~>3.1.1 |
| <a name="module_init_hosts"></a> [init\_hosts](#module\_init\_hosts) | ./modules/init | n/a |
| <a name="module_install_abm"></a> [install\_abm](#module\_install\_abm) | ./modules/install | n/a |
| <a name="module_instance_template"></a> [instance\_template](#module\_instance\_template) | terraform-google-modules/vm/google//modules/instance_template | ~> 7.8.0 |
| <a name="module_worker_vm_hosts"></a> [worker\_vm\_hosts](#module\_worker\_vm\_hosts) | ./modules/vm | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.lb-firewall-rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_filestore_instance.cluster-abm-nfs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/filestore_instance) | resource |
| [local_file.cluster_yaml_bundledlb](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.cluster_yaml_manuallb](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.init_args_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.nfs_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_abm_cluster_id"></a> [abm\_cluster\_id](#input\_abm\_cluster\_id) | Unique id to represent the Anthos Cluster to be created | `string` | `"cluster1"` | no |
| <a name="input_anthos_service_account_name"></a> [anthos\_service\_account\_name](#input\_anthos\_service\_account\_name) | Name given to the Service account that will be used by the Anthos cluster components | `string` | `"baremetal-gcr"` | no |
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | Size of the primary boot disk to be attached to the Compute Engine VMs in GBs | `number` | `200` | no |
| <a name="input_boot_disk_type"></a> [boot\_disk\_type](#input\_boot\_disk\_type) | Type of the boot disk to be attached to the Compute Engine VMs | `string` | `"pd-ssd"` | no |
| <a name="input_connect_agent_account"></a> [connect\_agent\_account](#input\_connect\_agent\_account) | GCP account email address to use with Connect Agent for logging into the cluster using Google Cloud identity. | `string` | `""` | no |
| <a name="input_credentials_file"></a> [credentials\_file](#input\_credentials\_file) | Path to the Google Cloud Service Account key file.<br>    This is the key that will be used to authenticate the provider with the Cloud APIs | `string` | n/a | yes |
| <a name="input_enable_nested_virtualization"></a> [enable\_nested\_virtualization](#input\_enable\_nested\_virtualization) | Enable nested virtualization on the Compute Engine VMs are to be scheduled | `string` | `"true"` | no |
| <a name="input_gpu"></a> [gpu](#input\_gpu) | GPU information to be attached to the provisioned GCE instances.<br>    See https://cloud.google.com/compute/docs/gpus for supported types | `object({ type = string, count = number })` | <pre>{<br>  "count": 0,<br>  "type": ""<br>}</pre> | no |
| <a name="input_image"></a> [image](#input\_image) | The source image to use when provisioning the Compute Engine VMs.<br>    Use 'gcloud compute images list' to find a list of all available images | `string` | `"ubuntu-2004-focal-v20210429"` | no |
| <a name="input_image_family"></a> [image\_family](#input\_image\_family) | Source image to use when provisioning the Compute Engine VMs.<br>    The source image should be one that is in the selected image\_project | `string` | `"ubuntu-2004-lts"` | no |
| <a name="input_image_project"></a> [image\_project](#input\_image\_project) | Project name of the source image to use when provisioning the Compute Engine VMs | `string` | `"ubuntu-os-cloud"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to provision per layer (Control plane and Worker nodes) of the cluster | `map(any)` | <pre>{<br>  "controlplane": 3,<br>  "worker": 2<br>}</pre> | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Google Cloud machine type to use when provisioning the Compute Engine VMs | `string` | `"n1-standard-8"` | no |
| <a name="input_min_cpu_platform"></a> [min\_cpu\_platform](#input\_min\_cpu\_platform) | Minimum CPU architecture upon which the Compute Engine VMs are to be scheduled | `string` | `"Intel Haswell"` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | Indication of the execution mode. By default the terraform execution will end<br>    after setting up the GCE VMs where the Anthos bare metal clusters can be deployed.<br><br>    **setup:** create and initialize the GCE VMs required to install Anthos bare metal.<br><br>    **install:** everything up to 'setup' mode plus automatically run Anthos bare metal installation steps as well.<br><br>    **manuallb:** similar to 'install' mode but Anthos on bare metal is installed with ManualLB mode. | `string` | `"setup"` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC network to which the provisioned Compute Engine VMs is to be connected to | `string` | `"default"` | no |
| <a name="input_nfs_server"></a> [nfs\_server](#input\_nfs\_server) | Provision a Google Filestore instance for NFS shared storage | `bool` | `false` | no |
| <a name="input_primary_apis"></a> [primary\_apis](#input\_primary\_apis) | List of primary Google Cloud APIs to be enabled for this deployment | `list(string)` | <pre>[<br>  "cloudresourcemanager.googleapis.com"<br>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud Region in which the Compute Engine VMs should be provisioned | `string` | `"us-central1"` | no |
| <a name="input_resources_path"></a> [resources\_path](#input\_resources\_path) | Path to the resources folder with the template files | `string` | n/a | yes |
| <a name="input_secondary_apis"></a> [secondary\_apis](#input\_secondary\_apis) | List of secondary Google Cloud APIs to be enabled for this deployment | `list(string)` | <pre>[<br>  "anthos.googleapis.com",<br>  "anthosgke.googleapis.com",<br>  "container.googleapis.com",<br>  "gkeconnect.googleapis.com",<br>  "gkehub.googleapis.com",<br>  "serviceusage.googleapis.com",<br>  "stackdriver.googleapis.com",<br>  "monitoring.googleapis.com",<br>  "logging.googleapis.com",<br>  "iam.googleapis.com",<br>  "compute.googleapis.com",<br>  "anthosaudit.googleapis.com",<br>  "opsconfigmonitoring.googleapis.com",<br>  "file.googleapis.com"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to be associated to the provisioned Compute Engine VMs | `list(string)` | <pre>[<br>  "http-server",<br>  "https-server"<br>]</pre> | no |
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
