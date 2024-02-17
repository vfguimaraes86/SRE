#####################################################################
# CARREGA OS DADOS DO CLOUDFRONT DO API
#####################################################################

data "aws_cloudfront_distribution" "api_cloudfront" {
  id   = var.cloudfront_id
}