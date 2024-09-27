#!/bin/bash

# Apply Terraform configuration
cd ..
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Wait for Terraform to complete
echo "Waiting for Terraform to finalize..."
sleep 10

# Process Terraform output using Python script
echo "Processing Terraform output..."
terraform output -json | python3 scripts/automation.py

# Wait for the Python script to complete
echo "Waiting for the Python script to complete..."
sleep 10

# Change to the Ansible directory
echo "Navigating to the Ansible directory..."
cd ansible

# Run Ansible playbook
echo "Running Ansible preparing playbook..."
sudo ansible-playbook -i inventory/inventory.ini playbooks/hardening.yml

echo "Waiting for 10 secound.."
sleep 10

echo "Running Ansible kube playbook for setup kuberntes cluster"
sudo ansible-playbook -i inventory/inventory.ini playbooks/kube.yml
