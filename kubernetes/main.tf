resource "kubectl_manifest" "storage_provisioner" {
  yaml_body = file("./storage/namespace.yml") 
    + "\n---\n" 
    + file("./storage/service-account.yml")
    + "\n---\n" 
    + file("./storage/cluster-role.yml")
    + "\n---\n" 
    + file("./storage/cluster-role-binding.yml")
    + "\n---\n" 
    + file("./storage/local-path-provisioner.yml")
    + "\n---\n" 
    + file("./storage/storageclass.yml")
    + "\n---\n" 
    + file("./storage/configmap.yml")
}

resource "kubectl_manifest" "metrics-server" {
  yaml_body = file("./metrices-server/service-account.yml") 
    + "\n---\n" 
    + file("./metrices-server/cluster-role.yml")
    + "\n---\n" 
    + file("./metrices-server/cluster-role-two.yml")
    + "\n---\n" 
    + file("./metrices-server/role-binding.yml")
    + "\n---\n" 
    + file("./metrices-server/cluster-role-binding.yml")
    + "\n---\n" 
    + file("./metrices-server/cluster-role-binding-two.yml")
    + "\n---\n" 
    + file("./metrices-server/metrics-server.yml")
    + "\n---\n" 
    + file("./metrices-server/service.yml")
    + "\n---\n" 
    + file("./metrices-server/api-service.yml")
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
