#####################################################################
# CARREGA OS DADOS DO LOAD BALANCE DOS POS
#####################################################################

data "aws_lb" "eks_pos_alb" {
  name  = "eks-pos-alb-${var.namespace}"
}