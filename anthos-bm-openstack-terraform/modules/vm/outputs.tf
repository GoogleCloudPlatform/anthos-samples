# Output the list of IDs of the OpenStack VMs created by this module
output "vm_ids" {
  value = flatten([
    for vmList in openstack_compute_instance_v2.openstack_instance[*] : [
      for vm in vmList : vm.id
    ]
  ])
}
