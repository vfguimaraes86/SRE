#####################################################################
# CARREGA OS DADOS DO LOAD BALANCE DOS PORTAL
#####################################################################

data "aws_lb" "eks_portal_alb" {
  count = local.enabled_portal_ingress ? 1 : 0
  name  = "eks-portal-alb-${var.namespace}"

  depends_on = [
    kubernetes_ingress_v1.portal_ingress
  ]
}