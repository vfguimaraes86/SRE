#####################################################################
# CRIA OS RECORDS PARA O ROUTE53 DO PORTAL
#####################################################################

resource "aws_route53_record" "create_route53" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.componentConfig.sub_domain == "www" && var.domain != "" ? "${var.domain}.${data.aws_route53_zone.route53_zone.name}" : "${var.componentConfig.sub_domain}${local.route53_domain}"
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.portal_cloudfront.domain_name
    zone_id                = data.aws_cloudfront_distribution.portal_cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
#  lifecycle {
#    ignore_changes = [
#      name
#    ]
#  }
}
