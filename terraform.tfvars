hcloud_password     = "your_token"
ssh_public_key_path = "~/.ssh/id_rsa.pub"

virtual_machines = {
  "master-server-1" = {
    server_name     = "master-server-1"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "master-server-2" = {
    server_name     = "master-server-2"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "master-server-3" = {
    server_name     = "master-server-3"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "worker-server-1" = {
    server_name     = "worker-server-1"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "worker-server-2" = {
    server_name     = "worker-server-2"
    server_type     = "cpx11"
    server_location = "nbg1"
  }
}