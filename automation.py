# you have to run this command ==> terraform output -json | python3 automation.py
import sys
import json

ANSIBLE_INVENTORY_PATH = "ansible/inventory/inventory.ini"

def parse_inventory(data):
    """Generate a list of server inventory entries."""
    return [
        f"{hostname} ansible_host={ip} ansible_user=root ansible_port=22"
        for hostname, ip in data["server_ips"]["value"].items()
    ]

def write_inventory_file(filepath, servers):
    """Write the server inventory to a file."""
    with open(filepath, 'w') as file:
        file.write("[all]\n")
        file.write("\n".join(servers) + "\n")

def main(inventory_path):
    """Main function to parse input data and write the inventory file."""
    json_data = sys.stdin.read()
    data = json.loads(json_data)
    
    servers = parse_inventory(data)
    write_inventory_file(inventory_path, servers)

if __name__ == "__main__":
    main(inventory_path=ANSIBLE_INVENTORY_PATH)
