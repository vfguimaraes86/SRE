variable "environment" {
  description = "Ambiente da execução"
  type        = string
}

variable "namespace" {
  description = "Namespace da aplicação"
  type        = string
}

variable "region" {
  description = "Região da aplicação"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "O nome da zona pública no Route53"
  type        = string
  default     = ""
}

variable "eks_cluster_name" {
  description = "Nome do cluster cluster"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Força a deleção dos buckets e secretsmanager"
  type        = bool
  default     = false
}

variable "domain" {
  description = "Lista de componentes"
  type        = string
}

variable "environmentConfig" {
  description = "Configurações do ambiente"
  type        = map(string)
}

variable "api_components" {
  description = "Lista de componentes de api"
  type        = list(map(string))
}

variable "portal_components" {
  description = "Lista de componentes de portal"
  type        = list(map(string))
  default     = []
}

variable "pos_components" {
  description = "Lista de componentes do pos"
  type        = list(map(string))
  default     = []
}

variable "create_static_bucket" {
  description = "Lista de componentes de static bucket"
  type        = list(map(string))
  default     = []
}

variable "cloudfront_timeout" {
  description = "Timeout do cloudfront origin"
  type        = string
  default     = ""  # Dias #
}

variable "cloudwatch_retention" {
  description = "Retention Cloudwatch"
  type        = string
  default     = ""   # Dias #
}

