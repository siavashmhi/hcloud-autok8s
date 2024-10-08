resource "kubectl_manifest" "storage_class" {
  yaml_body = file("./storage/storageclass.yaml")
}

resource "kubectl_manifest" "metrics_server" {
  yaml_body = file("./metrics-server/components.yaml")
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  namespace        = "ingress-nginx"
  create_namespace = true 
  wait = true 

  values = [
    file("./ingress-nginx/helm.values.yaml")  
  ]
}

resource "null_resource" "cert_manager_repo" {
  provisioner "local-exec" {
    command = <<EOT
      helm repo add jetstack https://charts.jetstack.io 
      helm repo list
      helm repo update
    EOT

    environment = {
      KUBECONFIG = "/root/.kube/config"
    }
  }
}

resource "null_resource" "cert_manager" {
  provisioner "local-exec" {
    command = <<EOT
      helm upgrade --install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        -f ./cert-manager/helm.values.yml
    EOT

    environment = {
      KUBECONFIG = "/root/.kube/config"
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "helm uninstall cert-manager --namespace cert-manager"
  }

  depends_on = [
    null_resource.cert_manager_repo
  ]
}

resource "kubectl_manifest" "clusterissuer" {
  yaml_body = file("./cert-manager/clusterissuer.yml")

  depends_on = [
    null_resource.cert_manager
  ]
}
