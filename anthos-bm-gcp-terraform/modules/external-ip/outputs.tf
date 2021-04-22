output "ips" {
  value = {
    for vmName, details in google_compute_address.external_ip_address :
    vmName => ({
      region  = details.region
      tier    = details.network_tier
      address = details.address
    })
  }
}
