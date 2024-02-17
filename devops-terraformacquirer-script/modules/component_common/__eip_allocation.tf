#####################################################################
# CARREGA ELASTIC IP EXISTENTE da SOFTWARE EXPRESS
#####################################################################

data "aws_eip" "eip_allocation" {
  count = local.enabled_nlb_software_express ? 1 : 0
  id = var.eip_allocation
}
