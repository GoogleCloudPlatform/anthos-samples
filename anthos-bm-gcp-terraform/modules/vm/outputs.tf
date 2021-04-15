output vm_info {
  value = flatten([
    for group in module.compute_instance[*] : [
      for vm_details in group : [
        for detail in vm_details.instances_details : {
          hostname   = detail.name
          internalIp = detail.network_interface.0.network_ip
          externalIp = detail.network_interface.0.access_config.0.nat_ip
        }
      ]
    ]
  ])
}
