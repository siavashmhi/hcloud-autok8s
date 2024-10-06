variable "hcloud_password" {
  type        = string
  description = "hcloud token."
}

variable "ssh_public_key_path" {
  type        = string
  description = "existing SSH public key file."
}

variable "virtual_machines" {
  type = map(object({
    server_name     = string
    server_type     = string
    server_location = string
  }))
  description = "description"
}
