#!/bin/bash

set -e  
set -o pipefail  

# Function to run Ansible playbooks with a common structure
run_playbook() {
  local playbook=$1
  echo "Running Ansible playbook: $playbook..."
  sudo ansible-playbook -i inventory/inventory.ini playbooks/$playbook.yml
  echo "Waiting for 10 seconds..."
  sleep 10
}

# Apply Terraform configuration
echo "Applying Terraform configuration..."
cd Infrastructure/
terraform apply -auto-approve

# Wait for Terraform to complete
echo "Waiting for Terraform to finalize..."
sleep 10

# Process Terraform output using Python script
echo "Create Ansible inventory.ini file with terraform output.."
terraform output -json | python3 ../scripts/automation.py

# Change to the Ansible directory
echo "Navigating to the Ansible directory..."
cd ../ansible

# Run Ansible playbooks
run_playbook "hardening"
run_playbook "kube_load_balancer"
run_playbook "ingress_load_balancer"
# run_playbook "master_nodes"
# run_playbook "worker_nodes"
