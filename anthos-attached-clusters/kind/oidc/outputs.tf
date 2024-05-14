
output "issuer" {
  value = local.issuer_json.issuer
}

output "jwks" {
  value = base64encode(data.http.jwks.response_body)
}
