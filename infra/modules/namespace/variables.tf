variable "name" {
  description = "Nom du namespace"
  type        = string
  default     = "capstone"
}

variable "labels" {
  description = "Labels additionnels du namespace"
  type        = map(string)
  default     = {}
}
