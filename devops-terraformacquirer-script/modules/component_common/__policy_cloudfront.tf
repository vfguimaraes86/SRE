#####################################################################
# CARREGA OS DADOS DA POLICY PARA CONFIGURAR Cache policy and origin request policy (recommended)
#####################################################################

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}