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
