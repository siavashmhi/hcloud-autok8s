resource "kubectl_manifest" "metrics_server" {
  yaml_body = data.http.metrics_server_yaml.body
}

resource "kubectl_patch" "metrics_server_patch" {
  target {
    kind = "Deployment"
    name = "metrics-server"
    namespace = "kube-system"  
  }

  patch = <<EOF
spec:
  template:
    spec:
      containers:
        - name: metrics-server
          args:
            - --kubelet-insecure-tls
            - --authorization-always-allow-paths=/livez,/readyz
EOF

  depends_on = [
    kubectl_manifest.metrics_server  
  ]
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  chart            = "ingress-nginx/ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true  
  
  repository = "https://kubernetes.github.io/ingress-nginx"
  
  # Reference the external values file
  values = [
    file("./ingress-nginx/helm.values.yaml")  
  ]
}
