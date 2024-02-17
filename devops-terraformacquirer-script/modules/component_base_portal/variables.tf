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
}

variable "hosted_zone_id" {
  description = "O nome da zona pública no Route53"
  type        = string
}

variable "force_destroy" {
  description = "Força a deleção dos buckets e secretsmanager"
  type        = bool
}

variable "domain" {
  description = "Lista de componentes"
  type        = string
}

variable "environmentConfig" {
  description = "Configurações do ambiente"
  type        = map(string)
}

variable "componentConfig" {
  description = "Configurações da aplicação"
  type        = map(string)
}

variable "inbound_cidrs" {
  description = "Ips de entrada"
  type        = string
}

variable "cloudfront_id" {
  description = "ID do CloudFront"
  type = string
}

variable "eks_cluster_name" {
  description = "Nome do cluster cluster"
  type        = string
}