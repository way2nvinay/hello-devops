terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-devops-lab"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "hello-devops-tf"
    labels = {
      managed-by = "terraform"
      project    = "hello-devops"
    }
  }
}
