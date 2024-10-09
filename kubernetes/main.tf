resource "kubectl_manifest" "storage_provisioner_namespace" {
  yaml_body = file("./storage/namespace.yml")
}

resource "kubectl_manifest" "storage_provisioner_service_account" {
  yaml_body = file("./storage/service-account.yml")
  depends_on = [kubectl_manifest.storage_provisioner_namespace]
}

resource "kubectl_manifest" "storage_provisioner_cluster_role" {
  yaml_body = file("./storage/cluster-role.yml")
  depends_on = [kubectl_manifest.storage_provisioner_service_account]
}

resource "kubectl_manifest" "storage_provisioner_cluster_role_binding" {
  yaml_body = file("./storage/cluster-role-binding.yml")
  depends_on = [kubectl_manifest.storage_provisioner_cluster_role]
}

resource "kubectl_manifest" "storage_provisioner_storageclass" {
  yaml_body = file("./storage/storageclass.yml")
}

resource "kubectl_manifest" "storage_provisioner_configmap" {
  yaml_body = file("./storage/configmap.yml")
  depends_on = [kubectl_manifest.storage_provisioner_storageclass]
}

resource "kubectl_manifest" "storage_provisioner_local_path" {
  yaml_body = file("./storage/local-path-provisioner.yml")
  depends_on = [
    kubectl_manifest.storage_provisioner_namespace,
    kubectl_manifest.storage_provisioner_service_account,
    kubectl_manifest.storage_provisioner_cluster_role,
    kubectl_manifest.storage_provisioner_cluster_role_binding,
    kubectl_manifest.storage_provisioner_storageclass,
    kubectl_manifest.storage_provisioner_configmap
  ]
}

resource "kubectl_manifest" "metrics_server_service_account" {
  yaml_body = file("./metrics-server/service-account.yml")
}

resource "kubectl_manifest" "metrics_server_cluster_role" {
  yaml_body = file("./metrics-server/cluster-role.yml")
}

resource "kubectl_manifest" "metrics_server_cluster_role_two" {
  yaml_body = file("./metrics-server/cluster-role-two.yml")
}

resource "kubectl_manifest" "metrics_server_role_binding" {
  yaml_body = file("./metrics-server/role-binding.yml")
  depends_on = [kubectl_manifest.metrics_server_service_account]
}

resource "kubectl_manifest" "metrics_server_cluster_role_binding" {
  yaml_body = file("./metrics-server/cluster-role-binding.yml")
  depends_on = [kubectl_manifest.metrics_server_service_account]
}

resource "kubectl_manifest" "metrics_server_cluster_role_binding_two" {
  yaml_body = file("./metrics-server/cluster-role-binding-two.yml")
  depends_on = [kubectl_manifest.metrics_server_service_account]
}

resource "kubectl_manifest" "metrics_server_deployment" {
  yaml_body = file("./metrics-server/metrics-server.yml")
  depends_on = [
    kubectl_manifest.metrics_server_service_account,
    kubectl_manifest.metrics_server_cluster_role,
    kubectl_manifest.metrics_server_cluster_role_two
  ]
}

resource "kubectl_manifest" "metrics_server_service" {
  yaml_body = file("./metrics-server/service.yml")
  depends_on = [kubectl_manifest.metrics_server_deployment]
}

resource "kubectl_manifest" "metrics_server_api_service" {
  yaml_body = file("./metrics-server/api-service.yml")
  depends_on = [kubectl_manifest.metrics_server_service]
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
