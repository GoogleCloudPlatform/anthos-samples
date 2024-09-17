## Google Cloud Loadbalancer Module

This module creates and configures a GCP Loadbalancer. It also creates an
external IP address configured to forward traffic from this IP to the
loadbalancer.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend\_protocol | The type of network traffic that the loadbalancer is expected to load balance.<br>  This attribute defines the type of loadbalancer that is created.<br>  https://cloud.google.com/load-balancing/docs/load-balancing-overview#summary-of-google-cloud-load-balancers | `string` | n/a | yes |
| forwarding\_rule\_ports | List of ports on the external IP address (created by this module) that should<br>  have a forwarding rule associated to them. The forwarding rule configures<br>  traffic to these ports on the external IP to be forwarded to the loadbalancer. | `list(number)` | <pre>[<br>  443,<br>  80<br>]</pre> | no |
| health\_check\_path | URL context to use when pinging the backend instances (of the loadbalancer) to<br>  do health checks. Health checks are used to verify if the instance is<br>  available to receive loadbalanced traffic | `string` | `"/readyz"` | no |
| health\_check\_port | Network port on the backend instance to use when pinging to do health checks.<br>  Health checks are used to verify if the instance is available to receive<br>  loadbalanced traffic | `number` | `6444` | no |
| ip\_name | Name to be given to the external IP that is created to expose the loadbalancer | `string` | n/a | yes |
| lb\_endpoint\_instances | Details (name, port, ip) of the backend instances that the loadbalancer will<br>  distribute traffic to | `list(object({ name = string, port = number, ip = string }))` | `[]` | no |
| name\_prefix | Prefix to associate to the names of the loadbalancer resources created by this module | `string` | n/a | yes |
| network | VPC network to which the loadbalancer resources are connected to | `string` | `"default"` | no |
| project | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| type | Indication of the type of loadbalancer you want to create; whether it is a<br>    L4 loadbalancer for the control plane of the cluster or a L7 loadbalancer<br>    for the Ingress controller. Supported values are: controlplanelb, ingresslb | `string` | n/a | yes |
| zone | Zone within the selected Google Cloud Region that is to be used | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| neg\_name | The name of the network endpoint group (https://cloud.google.com/load-balancing/docs/negs#zonal-neg)<br>        that was created as part of the load balancer setup |
| public\_ip | The external ip that can be used to reach the loadbalancer that was created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
