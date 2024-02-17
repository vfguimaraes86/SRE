#####################################################################
# CRIA O RDS PARA O AMBIENTE PRODUTIVO
#####################################################################
/*
locals {
  enabled_rds_prd    = try(var.api_components.value["rds"], false)
  rds_username       = "administrator"
}

resource "aws_rds" "rds_prd" {
  count       = local.enabled_rds_prd ? 1 : 0
  #infos do RDS

    tags = {
    Service   = "${var.api_components.value["sub-domain"]}_rds_prd"
    Component = "common"
  }
}*/
