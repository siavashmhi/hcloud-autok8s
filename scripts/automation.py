# you have to run this command ==> terraform output -json | python3 automation.py
import sys
import json

ANSIBLE_INVENTORY_PATH = "ansible/inventory/inventory.ini"

def generate_inventory_group(host_pattern, server_ips):
    """Generate inventory entries for a specific group of servers based on a hostname pattern."""
    return [
        f"{hostname} ansible_host={ip} ansible_user=root ansible_port=22"
        for hostname, ip in server_ips.items() if hostname.startswith(host_pattern)
    ]

def parse_inventory(data):
    """Parse the JSON data and generate server inventory entries for all groups."""
    server_ips = data["server_ips"]["value"]

    master_servers = generate_inventory_group("master", server_ips)
    worker_servers = generate_inventory_group("worker", server_ips)
    load_balancer_servers = generate_inventory_group("haproxy", server_ips)
    all_servers = [
        f"{hostname} ansible_host={ip} ansible_user=root ansible_port=22"
        for hostname, ip in server_ips.items()
    ]

    return all_servers, master_servers, worker_servers, load_balancer_servers

def write_inventory_file(filepath, all_servers, masters, workers, load_balancers):
    """Write the server inventory to a file in the appropriate INI format."""
    with open(filepath, 'w') as file:
        file.write("[kubernetes-masters]\n")
        file.write("\n".join(masters) + "\n\n")

        file.write("[kubernetes-workers]\n")
        file.write("\n".join(workers) + "\n\n")

        file.write("[load-balancer-servers]\n")
        file.write("\n".join(load_balancers) + "\n\n")

        file.write("[all:children]\n")
        file.write("\n".join(all_servers) + "\n\n")

def main(inventory_path):
    """Main function to handle the input JSON and write the inventory file."""
    json_data = sys.stdin.read()
    data = json.loads(json_data)

    all_servers, masters, workers, load_balancers = parse_inventory(data)
    write_inventory_file(inventory_path, all_servers, masters, workers, load_balancers)

if __name__ == "__main__":
    main(ANSIBLE_INVENTORY_PATH)
