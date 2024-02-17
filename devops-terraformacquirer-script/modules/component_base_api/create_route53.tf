#####################################################################
# CRIA O ROUTE53 PARA A API
#####################################################################

resource "aws_route53_record" "create_route53" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${var.componentConfig.sub_domain}${local.route53_domain}"
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.api_cloudfront.domain_name
    zone_id                = data.aws_cloudfront_distribution.api_cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

