#####################################################################
# CRIA O NAMESPACE NO EKS
#####################################################################
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
