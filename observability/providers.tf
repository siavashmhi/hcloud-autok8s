terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "/root/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "/root/.kube/config"
}

provider "kubectl" {
  config_path = "/root/.kube/config"
}
