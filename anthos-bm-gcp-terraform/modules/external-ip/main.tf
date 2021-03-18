resource "google_compute_address" "external_ip_address" {
  for_each = toset(var.vm_names)
  name = each.value
}
