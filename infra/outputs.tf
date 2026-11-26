output "namespace" {
  description = "Nom du namespace cree"
  value       = module.namespace.name
}

output "configmap_name" {
  description = "Nom du ConfigMap cree"
  value       = kubernetes_config_map.app.metadata[0].name
}
