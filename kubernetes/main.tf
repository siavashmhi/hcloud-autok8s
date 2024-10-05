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

resource "helm_release" "cert_manager" {
  name             = "cert_manager"
  chart            = "jetstack/cert-manager"
  namespace        = "cert_manager"
  create_namespace = true  
  
  repository = "https://charts.jetstack.io"
  
  # Reference the external values file
  values = [
    file("./cert-manager/helm.values.yml")  
  ]

  depends_on = [
    kubectl_manifest.metrics_server,
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "clusterissuer" {
  yaml_body = file("./cert-manager/clusterissuer.yml") 

  depends_on = [
    helm_release.cert_manager
  ] 
}

