#####################################################################
# CARREGA OS DADOS DO CERTIFICATE MANAGER
#####################################################################

data "aws_acm_certificate" "certificate_manager" {
  domain = "*.${data.aws_route53_zone.route53_zone.name}"
}