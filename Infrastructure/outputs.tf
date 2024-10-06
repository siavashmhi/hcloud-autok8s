# Output the public IPs of the created servers
output "server_ips" {
  value = {
    for vm_key, vm in var.virtual_machines :
    vm.server_name => hcloud_server.servers[vm_key].ipv4_address
  }
}
