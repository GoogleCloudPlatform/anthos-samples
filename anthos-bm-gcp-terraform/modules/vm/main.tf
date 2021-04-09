module external_ip_addresses {
  source   = "../external-ip"
  ip_names = var.vm_names
}

module compute_instance {
  source            = "terraform-google-modules/vm/google//modules/compute_instance"
  instance_template = var.instance_template
  region            = var.region
  for_each          = toset(var.vm_names)
  hostname          = each.value
  network           = var.network # --network default
  access_config = [{
    nat_ip       = module.external_ip_addresses.ips[each.value].address
    network_tier = module.external_ip_addresses.ips[each.value].tier
  }]
}
