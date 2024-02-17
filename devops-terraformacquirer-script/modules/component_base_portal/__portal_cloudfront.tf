#####################################################################
# CARREGA OS DADOS DO CLOUDFRONT DO PORTAL
#####################################################################

data "aws_cloudfront_distribution" "portal_cloudfront" {
  id   = var.cloudfront_id
}