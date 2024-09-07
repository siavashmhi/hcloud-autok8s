# Create a private network with a 192.168 IP range
resource "hcloud_network" "cluster_network" {
  name     = "cluster-network"
  ip_range = "192.168.0.0/16"
}

# Create a subnet for the network
resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.cluster_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "192.168.0.0/24"
}

# Create 4 Ubuntu servers with the specified SSH key, server type, and location
resource "hcloud_server" "servers" {
  for_each    = var.virtual_machines
  name        = each.value.server_name
  image       = "ubuntu-22.04"
  server_type = "cpx11"
  location    = "nbg1"
  ssh_keys    = ["Siavash-MacOs"]

  network {
    network_id = hcloud_network.cluster_network.id
  }

  depends_on = [
    hcloud_network.cluster_network,
    hcloud_network_subnet.subnet
  ]
}

# resource "hcloud_server" "servers" {
#   count       = length(var.ubuntu_servers)
#   name        = var.ubuntu_servers[count.index]
#   image       = "ubuntu-22.04"
#   server_type = "cx21"
#   location    = "nbg1"
#   ssh_keys    = ["Siavash-MacOs"]

#   network {
#     network_id = hcloud_network.cluster_network.id
#   }

#   depends_on = [
#     hcloud_network.cluster_network,
#     hcloud_network_subnet.subnet
#   ]
# }
