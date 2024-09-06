variable "hcloud_password" {
  type        = string
  description = "hcloud token."
}

variable "ubuntu_servers" {
  type        = list(string)
  description = "list of ubuntu servers."
}

variable "virtual_machines" {
  type = map(object({
    server_name = string
  }))
  description = "description"
  default = {
    "master-server-1" = {
      server_name = "master-server-1"
    }

    "master-server-2" = {
      server_name = "master-server-2"
    }

    "master-server-3" = {
      server_name = "master-server-3"
    }

    "worker-server-1" = {
      server_name = "worker-server-1"
    }

    "worker-server-2" = {
      server_name = "worker-server-2"
    }
  }
}

