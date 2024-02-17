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

variable "api_components" {
  description = "Lista de componentes de api"
  type        = list(map(string))
}

variable "portal_components" {
  description = "Lista de componentes de portal"
  type        = list(map(string))
}

variable "pos_components" {
  description = "Lista de componentes do pos"
  type        = list(map(string))
}

variable "create_static_bucket" {
  description = "Lista de componentes de static bucket"
  type        = list(map(string))
}

variable "inbound_cidrs" {
  description = "Ips de entrada"
  type        = string
}

variable "path" {
  description = "Caminho da aplicação"
  type        = string
}

variable "vpc" {
  description = "Id da VPC"
  type        = string
}

variable "restricted_subnets_ids" {
  description = "Id da VPC"
  type        = list(string)
}

variable "public_subnets_ids" {
  description = "id das subnets publicas"
  type = list(string)
}

variable "private_subnets_ids" {
  description = "id das subnets publicas"
  type = list(string)
}

variable "cloudfront_timeout" {
  description = "Timeout do cloudfront origin"
  type        = number
}

variable "cloudwatch_retention" {
  description = "Retention Cloudwatch"
  type        = number
}

variable "waf_regional" {
  description = "Carrega os dados do waf reginal"
  type = string
}

variable "waf_global" {
  description = "Carrega os dados do waf global"
  type = string
}

variable "eip_allocation" {
  description = "Carrega os dados do Elastic IP da Software Express"
  type = string
}

variable "eks_cluster_name" {
  description = "Nome do cluster cluster"
  type        = string
}
