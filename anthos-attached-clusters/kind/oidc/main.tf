
// this is a local library to manage getting OIDC info from the cluster

data "http" "issuer" {

  provider = http-full

  url = "${var.endpoint}/.well-known/openid-configuration"
  request_headers = {
    content-type = "application/jwk-set+json"
  }

  ca         = var.cluster_ca_certificate
  client_crt = var.client_certificate
  client_key = var.client_key
}

locals {
  issuer_json = jsondecode(data.http.issuer.response_body)
}

data "http" "jwks" {

  provider = http-full

  url = local.issuer_json.jwks_uri
  request_headers = {
    content-type = "application/json"
  }

  ca         = var.cluster_ca_certificate
  client_crt = var.client_certificate
  client_key = var.client_key
}

