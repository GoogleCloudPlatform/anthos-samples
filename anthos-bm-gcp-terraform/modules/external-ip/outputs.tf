output "ips" {
  value = {
    for vmName, details in google_compute_address.external_ip_address :
    vmName => ({
      tier    = details.network_tier
      address = details.address
    })
  }
}
