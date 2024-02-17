#####################################################################
# CARREGA OS DADOS WAF
#####################################################################

data "aws_wafv2_web_acl" "waf_regional" {
  name  = var.waf_regional
  scope = "REGIONAL"
}