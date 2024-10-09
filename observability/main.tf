resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  create_namespace = true
  wait = true

  values = [
    file("./prometheus/helm.values.yaml")  
  ]
}

resource "kubectl_manifest" "prometheus_secrets" {
  yaml_body = file("./prometheus/secrets.yml")
  depends_on = [
    helm_release.prometheus_stack
  ]
}

resource "kubectl_manifest" "get_etcd_certs" {
  yaml_body = file("./prometheus/get-etcd-cert.yml")
  depends_on = [
    helm_release.prometheus_stack,
    kubectl_manifest.prometheus_secrets
  ]
}

# Get the pod name with busybox in the 'default' namespace
resource "null_resource" "get_pod_name" {
  provisioner "local-exec" {
    command = <<EOT
      podname=$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' -n default | grep busybox)
      echo $podname
    EOT
    # Capture the pod name output
    environment = {
      podname = "busybox"
    }
  }
  
  depends_on = [kubectl_manifest.get_etcd_certs]
}

# Create the etcd-client-cert secret in the 'monitoring' namespace
resource "null_resource" "create_etcd_client_cert_secret" {
  depends_on = [null_resource.get_pod_name]

  provisioner "local-exec" {
    command = <<EOT
      kubectl create secret generic etcd-client-cert -n monitoring \
      --from-literal=etcd-ca="$(kubectl exec $podname -n default -- cat /etc/kubernetes/pki/etcd/ca.crt)" \
      --from-literal=etcd-client="$(kubectl exec $podname -n default -- cat /etc/kubernetes/pki/apiserver-etcd-client.crt)" \
      --from-literal=etcd-client-key="$(kubectl exec $podname -n default -- cat /etc/kubernetes/pki/apiserver-etcd-client.key)"
    EOT
  }
}

resource "helm_release" "loki" {
  name       = "loki"
  chart      = "grafana/loki-stack"
  namespace  = "loki-stack"
  create_namespace = true

  values = [
    file("loki/helm.values.yaml")
  ]

  depends_on = [
    helm_release.prometheus_stack,
    kubectl_manifest.prometheus_secrets,
    kubectl_manifest.get_etcd_certs,
    null_resource.get_pod_name,
    null_resource.create_etcd_client_cert_secret
  ]
}
