resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  namespace        = "ingress-nginx"
  create_namespace = true  

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

resource "kubectl_manifest" "metrics_server" {
  yaml_body = file("./metric-server/metrics-server-components.yaml")
  
  depends_on = [
    kubectl_manifest.clusterissuer,
    null_resource.cert_manager,
    null_resource.cert_manager_repo,
    helm_release.nginx_ingress
  ]
}

resource "time_sleep" "wait_180_seconds" {
  create_duration = "180s"
}

resource "kubernetes_manifest" "metrics_server_patch" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "metrics-server"
      "namespace" = "kube-system"
    }
    "spec" = {
      "template" = {
        "spec" = {
          "containers" = [{
            "name" = "metrics-server"
            "args" = [
              "--kubelet-insecure-tls",
              "--authorization-always-allow-paths=/livez,/readyz"
            ]
          }]
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.metrics_server,
    time_sleep.wait_180_seconds
  ]
}
