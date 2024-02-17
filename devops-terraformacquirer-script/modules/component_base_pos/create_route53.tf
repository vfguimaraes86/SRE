#####################################################################
# CRIA O ROUTE53 PARA O POS
#####################################################################

resource "aws_route53_record" "create_route53" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${var.componentConfig.sub_domain}${local.route53_domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks_pos_alb.dns_name
    zone_id                = data.aws_lb.eks_pos_alb.zone_id
    evaluate_target_health = true
  }
#  lifecycle {
#    ignore_changes = [
#      name
#    ]
#  }
}
