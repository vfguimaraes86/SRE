#####################################################################
# CARREGA OS DADOS WAF
#####################################################################

data "aws_wafv2_web_acl" "waf_global" {
  provider = aws.n-virginia
  name     = var.waf_global
  scope    = "CLOUDFRONT"
}