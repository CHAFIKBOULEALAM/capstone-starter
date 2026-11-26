output "name" {
  description = "Nom du namespace cree"
  value       = kubernetes_namespace.this.metadata[0].name
}
