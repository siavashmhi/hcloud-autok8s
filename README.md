## Install High Available Kuberntes Cluster with Terraform and Ansible on Hetzner Cloud.

This is end to end automation project for install high available kubernetes cluster on hetzner cloud with Terraform and Ansible.

I use Terraform for create Kubernetes nodes and create private network and subnet in hcloud.
and after install kubernetes, I use Terraform for config kubernetes cluster.

I use Ansible as a configuration management and install kubernetes cluster.

## Prerequisites

- **Ansible:** Ensure Ansible is installed on your system.

- **Install the community.docker Collection -** You can install community.docker collection with this command:

```bash
ansible-galaxy collection install community.docker 
```

## Setup Instructions

### Step 1: Clone the Repository

To begin, clone this repository to your local machine:

```bash
git clone https://github.com/siavashmhi/hcloud-autok8s.git
cd hcloud-autok8s
```

### Step 2: Change terraform.tfvars variable file.

You have to set your hcloud token and ssh public key path in terraform.tfvars file.
and you have to set virtual machine configs in virtual_machines variable.

as default value i use cpx11 server type, this server have 2 core cpu and 2G memory and 40G disk, you can change this server type.

for see server types on Hetzner Cloud you can use thease commands:
```bash
cat server_types.json 

curl -H "Authorization: Bearer your_api_token" https://api.hetzner.cloud/v1/server_types
```

```bash
cat terraform.tfvars 

hcloud_password     = "your_hcloud_token" #change
ssh_public_key_path = "~/.ssh/id_rsa.pub" #change

virtual_machines = {
  "master1" = {
    server_name     = "master1"
    server_type     = "cpx11" #change
    server_location = "nbg1"
  }

  "master2" = {
    server_name     = "master2"
    server_type     = "cpx11" #change
    server_location = "nbg1"
  }

  "master3" = {
    server_name     = "master3"
    server_type     = "cpx11" #change
    server_location = "nbg1"
  }

  "worker1" = {
    server_name     = "worker1"
    server_type     = "cpx11" #change
    server_location = "nbg1"
  }

  "worker2" = {
    server_name     = "worker2"
    server_type     = "cpx11" #change
    server_location = "nbg1"
  }

  "kube-load-balancer" = {
    server_name     = "kube-load-balancer"
    server_type     = "cpx11" #change
    server_location = "nbg1"
  }

  "ingress-load-balancer" = {
    server_name     = "ingress-load-balancer"
    server_type     = "cpx11" #change
    server_location = "nbg1"
  }

}

```

### Step 3: Change kubernetes.yml variable file.

this is ansible variable file and use this for install kubernetes cluster.

```bash
cat ansible/inventory/group_vars/all/kubernetes.yml 

kubernetes_version: "1.30.0"
domain_name: "cloudflow.ir"
vip_api_name: "vip"
vip_ip_address: "vip.cloudflow.ir"
controlplane_endpoint: "vip.cloudflow.ir:6443"
master1_domain: "master1.cloudflow.ir"
master2_domain: "master2.cloudflow.ir"
master3_domain: "master3.cloudflow.ir"

# load-balancer cofigurations
haproxy_user: "siavash"
haproxy_password: "{SHA}27x1fULNcCWYFLK3dSKkc3t+I10="

# ingress load balancer configuraions
ingress_haproxy_panel_sub: "haproxy"
traefik_sub_domain: "traefik"
traefik_user: "siavash"
traefik_password: "{SHA}27x1fULNcCWYFLK3dSKkc3t+I10="
ingress_haproxy_user: "siavash"
ingress_haproxy_password: "cloudflow"
ingress_http_sub: "ingress1"
ingress_https_sub: "ingress2"

```