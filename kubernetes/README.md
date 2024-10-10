# Kubernetes Infrastructure Deployment with Terraform and Helm

This project automates the deployment of Kubernetes resources and Helm charts using Terraform. It sets up a local-path storage provisioner, metrics server, and installs `nginx-ingress` and `cert-manager` via Helm.

## Terraform will:

1. Deploy Ingress NGINX using a Helm chart.
2. Deploy the Metrics Server.
3. Deploy the Local Path Storage provisioner.
4. Deploy Cert Manager and configure a ClusterIssuer.

## Ingress nginx controller artchitect 

![Ingress nginx controller artchitect](../images/ingress-nginx.png "Ingress nginx controller artchitect")

## Prerequisites

Before starting, ensure you have the following installed on your local machine or environment:

1. [Terraform](https://www.terraform.io/downloads.html) 
2. [Helm](https://helm.sh/docs/intro/install/) 
3. [kubectl](https://kubernetes.io/docs/tasks/tools/)
4. Access to a Kubernetes cluster (with kubeconfig properly configured)

### Optional:

- A working knowledge of Terraform and Helm commands.
- Proper permissions to manage the Kubernetes cluster.

## Project Structure

The project contains several YAML configuration files for Kubernetes resources and Helm values:

- `./storage/` - Contains Kubernetes manifests for the storage provisioner.
- `./metrics-server/` - Contains Kubernetes manifests for the metrics server.
- `./ingress-nginx/` - Contains Helm values for nginx-ingress.
- `./cert-manager/` - Contains Helm values and Kubernetes manifests for cert-manager.

## Steps to Run

### 1. Clone the Repository

First, clone the project repository:

```bash
git clone https://github.com/siavashmhi/hcloud-autok8s.git
cd hcloud-autok8s/kubernetes
```

### 2. Initialize Terraform

Run the following command to initialize the Terraform configuration:

```bash
terraform init -upgrade
```

### 3. Customization

You can modify the Helm values for nginx-ingress and cert-manager in the following files before running terraform apply:

helm values for ingress nginx:

```bash
cat ./ingress-nginx/helm.values.yaml             

ingressClassResource:
  name: nginx
  enabled: true
  default: true
resources:
  limits:
    cpu: 500m
    memory: 1024Mi
  requests:
    cpu: 100m
    memory: 90Mi

service:
  nodePorts:
    http: 32080   
    https: 32443  
  type: NodePort

metrics:
  port: 10254
  enabled: true
  service:
    type: NodePort
    nodePort: "32254"
```

helm values for cert-manager:

```bash
cat ./cert-manager/helm.values.yml 

---
ingressShim:
  defaultIssuerGroup: cert-manager.io
  defaultIssuerKind: ClusterIssuer
  defaultIssuerName: letsencrypt
installCRDs: true   

```

### 4. Apply the Terraform Configuration

To deploy the Kubernetes resources and Helm charts, run the following Terraform command:

```bash
terraform apply
```

### 5. Verify the Deployment

You can verify that all the components have been deployed correctly by using kubectl commands:

```bash
# verify ingress nginx resources
kubectl get all -n ingress-nginx

# verify local-path storage provisioner resources
kubectl get all -n local-path-storage

# verify cert-manager resources
kubectl get all -n cert-manager

# verify metrics-server resources
kubectl get all -n kube-system | grep metrics-server
```

### Cleanup

If you want to remove the deployed resources, run:

```bash
terraform destroy
```

### Contributing

Contributions to improve or extend the functionality of this Terraform project are welcome. Please submit a pull request with a detailed explanation of your changes.
