locals {
  default_values = jsondecode(file("${path.module}/default_${local.eks_cluster_name}.json"))
}