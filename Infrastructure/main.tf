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

resource "hcloud_ssh_key" "main_ssh_key" {
  name       = "main_ssh_key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_server" "servers" {
  for_each    = var.virtual_machines
  name        = each.value.server_name
  image       = "ubuntu-22.04"
  server_type = each.value.server_type
  location    = each.value.server_location
  ssh_keys    = ["main_ssh_key"]

  network {
    network_id = hcloud_network.cluster_network.id
  }

  depends_on = [
    hcloud_network.cluster_network,
    hcloud_network_subnet.subnet,
    hcloud_ssh_key.main_ssh_key
  ]
}
