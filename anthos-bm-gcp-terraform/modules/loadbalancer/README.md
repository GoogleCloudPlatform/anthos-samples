## Google Cloud Loadbalancer Module

This module creates and configures a GCP Loadbalancer. It also creates an
external IP address configured to forward traffic from this IP to the
loadbalancer.

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
| <a name="module_public_ip"></a> [public\_ip](#module\_public\_ip) | ../external-ip | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_backend_service.lb-backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_global_forwarding_rule.lb-forwarding-rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_health_check.lb-health-check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_network_endpoint.lb-network-endpoint](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoint) | resource |
| [google_compute_network_endpoint_group.lb-neg](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoint_group) | resource |
| [google_compute_target_http_proxy.lb-target-http-proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_target_tcp_proxy.lb-target-tcp-proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_tcp_proxy) | resource |
| [google_compute_url_map.ingress-lb-urlmap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_protocol"></a> [backend\_protocol](#input\_backend\_protocol) | The type of network traffic that the loadbalancer is expected to load balance.<br>  This attribute defines the type of loadbalancer that is created.<br>  https://cloud.google.com/load-balancing/docs/load-balancing-overview#summary-of-google-cloud-load-balancers | `string` | n/a | yes |
| <a name="input_forwarding_rule_ports"></a> [forwarding\_rule\_ports](#input\_forwarding\_rule\_ports) | List of ports on the external IP address (created by this module) that should<br>  have a forwarding rule associated to them. The forwarding rule configures<br>  traffic to these ports on the external IP to be forwarded to the loadbalancer. | `list(number)` | <pre>[<br>  443,<br>  80<br>]</pre> | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | URL context to use when pinging the backend instances (of the loadbalancer) to<br>  do health checks. Health checks are used to verify if the instance is<br>  available to receive loadbalanced traffic | `string` | `"/readyz"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Network port on the backend instance to use when pinging to do health checks.<br>  Health checks are used to verify if the instance is available to receive<br>  loadbalanced traffic | `number` | `6444` | no |
| <a name="input_ip_name"></a> [ip\_name](#input\_ip\_name) | Name to be given to the external IP that is created to expose the loadbalancer | `string` | n/a | yes |
| <a name="input_lb_endpoint_instances"></a> [lb\_endpoint\_instances](#input\_lb\_endpoint\_instances) | Details (name, port, ip) of the backend instances that the loadbalancer will<br>  distribute traffic to | `list(object({ name = string, port = number, ip = string }))` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to associate to the names of the loadbalancer resources created by this module | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC network to which the loadbalancer resources are connected to | `string` | `"default"` | no |
| <a name="input_project"></a> [project](#input\_project) | Unique identifer of the Google Cloud Project that is to be used | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud Region in which the loadbalancer resources should be provisioned | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Indication of the type of loadbalancer you want to create; whether it is a<br>    L4 loadbalancer for the control plane of the cluster or a L7 loadbalancer<br>    for the Ingress controller. Supported values are: controlplanelb, ingresslb | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone within the selected Google Cloud Region that is to be used | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_neg_name"></a> [neg\_name](#output\_neg\_name) | The name of the network endpoint group (https://cloud.google.com/load-balancing/docs/negs#zonal-neg)<br>        that was created as part of the load balancer setup |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The external ip that can be used to reach the loadbalancer that was created |
<!-- END_TF_DOCS -->
