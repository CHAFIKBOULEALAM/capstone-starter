terraform {
  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kube_context
}

module "namespace" {
  source = "./modules/namespace"

  name = var.namespace
}

resource "kubernetes_config_map" "app" {
  metadata {
    name      = "api-config"
    namespace = module.namespace.name
  }

  data = {
    LOG_LEVEL = var.log_level
  }
}
