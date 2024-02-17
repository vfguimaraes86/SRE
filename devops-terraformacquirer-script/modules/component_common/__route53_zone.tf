#####################################################################
# CARREGA OS DADOS ROUTE53
#####################################################################

data "aws_route53_zone" "route53_zone" {
  zone_id      = var.hosted_zone_id
  private_zone = false
}

locals {
  route53_domain = (var.domain != "" ? "-${var.domain}.${data.aws_route53_zone.route53_zone.name}" : ".${data.aws_route53_zone.route53_zone.name}")
}