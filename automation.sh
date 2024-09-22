#!/bin/bash

# Apply Terraform configuration
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Wait for Terraform to complete
echo "Waiting for Terraform to finalize..."
sleep 10

# Process Terraform output using Python script
echo "Processing Terraform output..."
terraform output -json | python3 automation.py

# Wait for the Python script to complete
echo "Waiting for the Python script to complete..."
sleep 10

# Change to the Ansible directory
echo "Navigating to the Ansible directory..."
cd ansible

# Run Ansible playbook
echo "Running Ansible preparing playbook..."
sudo ansible-playbook -i inventory/inventory.ini playbooks/hardening.yml
