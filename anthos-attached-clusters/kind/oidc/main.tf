/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// this is a local library to manage getting OIDC info from the cluster

data "http" "issuer" {

  provider = http-full

  url = "${var.endpoint}/.well-known/openid-configuration"
  request_headers = {
    content-type = "application/json"
  }

  ca         = var.cluster_ca_certificate
  client_crt = var.client_certificate
  client_key = var.client_key
}

data "http" "jwks" {

  provider = http-full

  url = "${var.endpoint}/openid/v1/jwks"
  request_headers = {
    content-type = "application/json"
  }

  ca         = var.cluster_ca_certificate
  client_crt = var.client_certificate
  client_key = var.client_key
}

