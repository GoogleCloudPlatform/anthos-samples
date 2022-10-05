
## Apigee Hybrid on Anthos Baremetal on Google Compute Engine VMs with Terraform

This repository shows you how to install Apigee Hybrid on Anthos Cluster on bare metal running on Compute Engine. For more details please refer to ../anthos-bm-gcp-terraform


### Pre-requisites

- A workstation with access to internet _(i.e. Google Cloud APIs)_ with the following installed
  - [Git](https://www.atlassian.com/git/tutorials/install-git)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (>= v0.15.5, < v1.2)

- A [Google Cloud Project](https://console.cloud.google.com/cloud-resource-manager?_ga=2.187862184.1029435410.1614837439-1338907320.1614299892) _(in which the resources for the setup will be provisioned)_

- Enable Compute Engine API Services and Apigee API Services.

- Ensure that the default Compute Engine developer account has Editor role. You can also create a new service account for the compute engine with Editor and specify the service account name in terraform variables.

![Default Service Account](docs/images/default_service_account.png)

- A [Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) in the project that satisfies **one** of the following requirements and its **[key file downloaded](docs/create_sa_key.md)** to the workstation:
    - The Service Account has `Owner` and `Apigee Organization Administrator` permissions
    - The Service Account has both `Editor`, `Project IAM Admin` and `Apigee Organization Administrator` permissions
  The scripts to create service account and key creation is also mentioned in Quickstart module. 
-  Organizational Policy Constraints 
      Follwowing list of Policy needs to be enabled for the organizations. If these are not enabled at Organizations, please consider them for the project.

      |  Policy Name                                 | Constraint Name                                   | Effective Polciy |
      |  ------------------------------------------- | ------------------------------------------------- | ---------------- |
      | Disable service account creation             | constraints/iam.disableServiceAccountCreation	   | Not Enforced     |
      | Disable service account key creation         | constraints/iam.disableServiceAccountKeyCreation	 | Not enforced     |
      | Restrict VM IP Forwarding                    | constraints/compute.vmCanIpForward	         | Allowed All      | 
      | Define allowed external IPs for VM instances | constraints/compute.vmExternalIpAccess	           | Allowed All      |
      | Shielded VMs                                 | constraints/compute.requireShieldedVm	           | Not Enforced     |
      | Require OS Login                             | constraints/compute.requireOsLogin	               | Not Enforced     |
      | Skip default network creation                | constraints/compute.skipDefaultNetworkCreation	   | Not Enforced     |


- Default Network with default Firewall policies 
The installation requires a network with name as default. If default network creation is enabled for the organization, the project will get them inherited. In case the  Skip default network creation is Enforced, you can create a new VPC network with name default in auto mode.
![Default Network](docs/images/default_network.png)

- Quota Check 
The demo Apigee instance requires 4 VMs with n1-standard-8 machine type. Please ensure there are enough quota set for CPU,Memory, IP Addresses for the region you are hosting the project.

- **Sample Prerequisite script is also provided unnder resources folder as ./resources/run_prerequisite.sh**

### Bare metal infrastructure on Google Cloud using Compute Engine VMs

The [Quick starter](docs/quickstart.md) guide sets up the following infrastructure in Google Cloud using Compute Engine VMs. The diagram assumes that the none of the default values for the [variables](variables.tf) were changed other than the ones mentioned in the quick starter.

![Bare metal infrastructure on Google Cloud using Compute Engine VMs](docs/images/abm_gcp_infra.png)

---
## Getting started

- [Terraform Module Information _(includes variables definitions)_](docs/variables.md)
- [Quick starter guide](docs/quickstart.md):
    - The terraform script sets up the GCE VM environment. The output of the script prints out the commands to follow to install **Anthos on bare metal** in the provisioned GCE VMs.


---
## Contributing

#### Pre-requisites
- The same [pre-requisites](#pre-requisites) to run this sample is required for testing as well

#### Pull requests
- For improvements to this sample submit your pull requests to the `main` branch

#### Testing
- Ensure that the improvements have _unit/integration tests_ where appropriate
- To run the existing tests you have to set two environment variables
```bash
export GOOGLE_CLOUD_PROJECT="<YOUR_GOOGLE_CLOUD_PROJECT>"
export GOOGLE_APPLICATION_CREDENTIALS="<PATH_TO_THE_SERVICE_ACCOUNT_KEY_FILE>"
```
- Move into the test directory and recursively execute the tests
```bash
cd ../anthos-bm-gcp-terraform/test
go test -v -timeout 30m ./...
```
