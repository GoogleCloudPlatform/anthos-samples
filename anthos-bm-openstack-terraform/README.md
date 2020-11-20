# Terraform example to create OpenStack VMs for Anthos
This repository contains an example of what OpenStack resources you need to
create for setting up Anthos on Bare Metal. The following resources are
created as part of the Terraform module:
- External Load Balancer using Octavia LBaaS
- Private Network for the VMs
- A router to provide external connectivity and for floating IP addresses
- 3 Nova VMs: 1 Admin workstation, 1 Control plane and 1 worker node
- Security Group that allows all ICNM and incoming TCP on port 22 and 443
  from 0.0.0.0/0
- Private SSH key that is uploaded to all VMs
- A cloud-config that sets up SSH access to all VMs from all VMs under
  the user `abm`

## Getting started

Clone the repo
```
git clone https://github.com/GoogleCloudPlatform/anthos-samples
cd anthos-samples/anthos-bm-openstack-terraform
```

Find your OpenStack external network ID
```
openstack network list
```

Create the file terraform.tfstate that contains your OpenStack credentials
```
source openrc # again if needed
cat > terraform.tfvars << EOF
external_network_id = "REPLACE_WITH_EXTERNAL_NETWORK_ID"
os_user_name        = "$OS_USERNAME"
os_tenant_name      = "$OS_TENANT_NAME"
os_password         = "$OS_PASSWORD"
os_auth_url         = "$OS_AUTH_URL"
os_endpoint_type    = "$OS_ENDPOINT_TYPE"
EOF
```

Review the terraform.tfvars file to make sure all the credentials are correct.
Especially make sure the `os_auth_url` and `os_endpoint_type` are set
correctly. The machine you're running terraform from needs to be able to
access the `auth_url` and the endpoints returned by keystone
```
cat terraform.tfvars
```

Review and edit the main.tf terraform script to your needs
```
cat main.tf
```

Review the cloud-config.yaml file that contains the scripts run on each VM. Please edit if needed:
```
cat cloud-config.yaml
```

Run terraform to create the resources
```
terraform init
terraform apply
```

Wait for all VMs to be ready and SSH into the admin ws VM called abm-ws
```
floating_ip=$(terraform output admin_ws_public_ip)
ssh ubuntu@$floating_ip
```

Become the abm user which has SSH access to the control plane node and worker node
```
sudo -u abm -i
```

Verify that you can SSH into the other nodes from the admin workstation
```
ssh abm@10.200.0.11 'echo SSH to $HOSTNAME succeeded'
ssh abm@10.200.0.12 'echo SSH to $HOSTNAME succeeded'
```

You now have the required infrastructure to deploy an Anthos on Bare Metal
2 node cluster. The node `10.200.0.11` can be used for the control plane
and the `10.200.0.12` can be used as worker node. The `10.200.0.101` IP
address that is assigned to the load balancer can be used as the control
plane VIP with manual LB mode.
