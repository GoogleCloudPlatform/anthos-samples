resource "google_container_azure_client" "this" {
  name           = "${var.anthos_prefix}-azure-client"
  location       = var.location
  tenant_id      = var.tenant_id
  application_id = var.application_id
}

