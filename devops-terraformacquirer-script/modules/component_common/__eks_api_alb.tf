#####################################################################
# CARREGA OS DADOS DO LOAD BALANCE DAS APIS
#####################################################################

data "aws_lb" "eks_api_alb" {
  count = local.enabled_api_ingress ? 1 : 0
  name  = "eks-api-alb-${var.namespace}"

  depends_on = [
    kubernetes_ingress_v1.api_ingress
  ]
}