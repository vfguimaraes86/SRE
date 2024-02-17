#####################################################################
# CARREGA OS DADOS DO CERTIFICATE MANAGER NORTE VIRGINIA
#####################################################################

data "aws_acm_certificate" "certificate_manager_us" {

  provider = aws.n-virginia

  domain      = "*.${data.aws_route53_zone.route53_zone.name}"
  most_recent = true
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
}
