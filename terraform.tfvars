hcloud_password     = "your_hcloud_token"
ssh_public_key_path = "~/.ssh/id_rsa.pub"

virtual_machines = {
  "master1" = {
    server_name     = "master1"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "master2" = {
    server_name     = "master2"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "master3" = {
    server_name     = "master3"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "worker1" = {
    server_name     = "worker1"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "worker2" = {
    server_name     = "worker2"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "kube-load-balancer" = {
    server_name     = "kube-load-balancer"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

  "ingress-load-balancer" = {
    server_name     = "ingress-load-balancer"
    server_type     = "cpx11"
    server_location = "nbg1"
  }

}
