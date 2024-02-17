#####################################################################
# CRIA NO ROUTE 53 PARA O SUBDOMINIO KIBANA
#####################################################################
locals {
  enabled_route53_kibana = try(var.environmentConfig["route53_kibana"], false) && try(var.environmentConfig["elasticsearch"], false)
  enabled_route53_elasticsearch = try(var.environmentConfig["route53_elasticsearch"], false) && try(var.environmentConfig["elasticsearch"], false)
}

resource "aws_route53_record" "route53_kibana" {
  count   = local.enabled_route53_kibana ? 1 : 0
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "kibana${local.route53_domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks_internal_alb[0].dns_name
    zone_id                = data.aws_lb.eks_internal_alb[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "route53_elasticsearch" {
  count   = local.enabled_route53_elasticsearch ? 1 : 0
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "elasticsearch${local.route53_domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks_internal_alb[0].dns_name
    zone_id                = data.aws_lb.eks_internal_alb[0].zone_id
    evaluate_target_health = true
  }
}