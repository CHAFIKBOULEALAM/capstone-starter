variable "namespace" {
  description = "Nom du namespace Kubernetes a creer"
  type        = string
  default     = "capstone"
}

variable "kube_context" {
  description = "Contexte kubectl du cluster local (docker-desktop ou kind-devops)"
  type        = string
  default     = "docker-desktop"
}

variable "log_level" {
  description = "Valeur de LOG_LEVEL dans le ConfigMap api-config"
  type        = string
  default     = "info"
}
