## Initialize VMs Module

This module copies the required configuration files and scripts _(from the [resources](/anthos-bm-gcp-terraform/resources) directory)_ into the GCE VMs and runs the
initialization steps.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_yaml\_path | Path to the YAML configuration file describing the Anthos cluster | `string` | `"../../resources/.cluster1.yaml"` | no |
| credentials\_file | Path to the Google Cloud Service Account key file.<br>    This is the key that will be used to authenticate the provider with the Cloud APIs | `string` | n/a | yes |
| hostname | Hostname of the target VM | `string` | n/a | yes |
| init\_check\_script | Path to the script that validates if the initialization is complete | `string` | `"../../resources/run_initialization_checks.sh"` | no |
| init\_logs | Name of the file to write the logs of the initialization script | `string` | `"init.log"` | no |
| init\_script | Path to the initilization script that is to be run on the target VM | `string` | `"../../resources/init_vm.sh"` | no |
| init\_vars\_file | Path to the file containing the host specific arguments to the init script | `string` | n/a | yes |
| install\_abm\_script | Path to the script that installs Anthos on bare metal | `string` | `"../../resources/install_abm.sh"` | no |
| login\_script | Path to the script that generates the token used to login to the Anthos bare metal cluster | `string` | `"../../resources/login.sh"` | no |
| module\_depends\_on | List of modules or resources this module depends on. | `list(any)` | `[]` | no |
| nfs\_yaml\_path | Path to the NFS YAML configuration file for the Anthos cluster | `string` | `"../../resources/.nfs-csi.yaml"` | no |
| priv\_key\_path\_template | Template denoting the path where the private key is to be stored | `string` | `"../../resources/.ssh-key-%s.priv"` | no |
| project\_id | Google Cloud Project where the target resources live | `string` | n/a | yes |
| pub\_key\_path\_template | Template denoting the path where the public key is to be stored | `string` | `"../../resources/.ssh-key-%s.pub"` | no |
| publicIp | Publicly accessible IP address of the target VM | `string` | n/a | yes |
| resources\_path | Path to the resources folder with the template files | `string` | n/a | yes |
| terraform\_sa\_path | Path inside the VMs to which the service account used for the Terraform run<br>    must be copied to. This Service Account is used for various actions when<br>    initializing the VM and installing Anthos on bare metal | `string` | n/a | yes |
| username | The name of the user to be created to execute the init script | `string` | `"tfadmin"` | no |
| zone | Google Cloud Zone where the target VM is in | `string` | `"us-central1-a"` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
