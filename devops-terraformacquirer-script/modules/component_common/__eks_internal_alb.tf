#####################################################################
# CARREGA OS DADOS DO LOAD BALANCE DAS APIS
#####################################################################

data "aws_lb" "eks_internal_alb" {
  count = local.enabled_ingress_internal ? 1 : 0
  name  = "eks-internal-alb-${var.namespace}"

  depends_on = [
    kubernetes_ingress_v1.ingress_internal
  ]
}